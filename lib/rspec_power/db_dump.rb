# frozen_string_literal: true

require "csv"
require "json"
require "time"
require "fileutils"

module RSpecPower
  module DbDumpHelpers
    DEFAULT_EXCLUDED_TABLES = %w[schema_migrations ar_internal_metadata].freeze

    def dump_database_on_failure(example, options = {})
      return unless defined?(::ActiveRecord)

      connection = ::ActiveRecord::Base.connection

      base_dir = resolve_base_dir(options[:dir])
      spec_label = sanitize_label(example.full_description)
      timestamp = Time.now.strftime("%Y%m%d-%H%M%S")

      tables = resolve_tables(connection, options)
      non_empty_tables = tables.select { |t| table_has_rows?(connection, t) }

      return nil if non_empty_tables.empty?

      out_dir = File.join(base_dir, "#{timestamp}_#{spec_label}")
      FileUtils.mkdir_p(out_dir)

      non_empty_tables.each do |table|
        csv_path = File.join(out_dir, "#{table}.csv")
        dump_table_to_csv(connection, table, csv_path)
      end

      write_metadata(out_dir, example, non_empty_tables)

      puts "[rspec_power] DB dump written to: #{out_dir}"
      puts "[rspec_power] Tables: #{non_empty_tables.join(", ")}" unless non_empty_tables.empty?

      out_dir
    rescue => e
      warn "[rspec_power] Failed to dump DB on failure: #{e.class}: #{e.message}"
      nil
    end

    private

    def resolve_base_dir(custom_dir)
      return custom_dir if custom_dir && !custom_dir.to_s.strip.empty?

      base = if defined?(Rails) && Rails.respond_to?(:root) && Rails.root
        Rails.root.join("tmp", "rspec_power", "db_failures").to_s
      else
        File.join(Dir.pwd, "tmp", "rspec_power", "db_failures")
      end
      FileUtils.mkdir_p(base)
      base
    end

    def resolve_tables(connection, options)
      specified = Array(options[:tables] || options[:only]).map(&:to_s)
      excluded = Array(options[:except] || options[:exclude]).map(&:to_s)

      all = connection.tables - DEFAULT_EXCLUDED_TABLES
      list = specified.empty? ? all : (all & specified)
      list - excluded
    end

    def table_has_rows?(connection, table)
      qt = connection.quote_table_name(table)
      sql = "SELECT 1 FROM #{qt} LIMIT 1"
      !connection.select_value(sql).nil?
    rescue
      false
    end

    def dump_table_to_csv(connection, table, csv_path)
      qt = connection.quote_table_name(table)
      primary_key = safe_primary_key(connection, table)

      sql = if primary_key
        qc = connection.quote_column_name(primary_key)
        "SELECT * FROM #{qt} ORDER BY #{qc} ASC"
      else
        "SELECT * FROM #{qt}"
      end

      result = connection.exec_query(sql)

      CSV.open(csv_path, "w") do |csv|
        csv << result.columns
        result.rows.each { |row| csv << row }
      end
    end

    def safe_primary_key(connection, table)
      connection.primary_key(table)
    rescue
      nil
    end

    def sanitize_label(label)
      label.to_s.gsub(/[^a-zA-Z0-9\-_]+/, "_")[0, 120]
    end

    def write_metadata(out_dir, example, tables)
      meta = {
        "spec" => example.full_description,
        "id" => example.id,
        "file_path" => example.metadata[:file_path],
        "exception" => example.exception&.message,
        "created_at" => Time.now.utc.iso8601,
        "tables" => tables
      }
      File.write(File.join(out_dir, "metadata.json"), JSON.pretty_generate(meta))
    rescue
      # Fallback to plain text if JSON isn't available for some reason
      File.write(
        File.join(out_dir, "metadata.txt"),
        [
          "spec: #{example.full_description}",
          "id: #{example.id}",
          "file_path: #{example.metadata[:file_path]}",
          "exception: #{example.exception&.message}",
          "created_at: #{Time.now.utc.iso8601}",
          "tables: #{tables.join(', ')}"
        ].join("\n")
      )
    end
  end
end

RSpec.shared_context "rspec_power::db_dump:on_fail" do
  include RSpecPower::DbDumpHelpers

  after(:each) do |example|
    dump_meta = example.metadata[:dump_db_on_fail]
    next unless dump_meta
    next unless example.exception

    options = dump_meta.is_a?(Hash) ? dump_meta : {}
    dump_database_on_failure(example, options)
  end
end
