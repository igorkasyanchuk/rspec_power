require_relative "./rails_helper"
require "csv"
require "tmpdir"

RSpec.describe "DB dump helpers" do
  include RSpecPower::DbDumpHelpers

  let(:connection) { ActiveRecord::Base.connection }

  after(:each) do
    %i[widgets empties alpha beta].each do |tbl|
      begin
        connection.drop_table(tbl)
      rescue StandardError
        # ignore
      end
    end
  end

  def build_example(label: "DB Dump spec example", file: __FILE__, error: StandardError.new("boom"))
    exception = error
    metadata = { file_path: file }
    Struct.new(:full_description, :id, :metadata, :exception).new(label, "example-id", metadata, exception)
  end

  it "dumps only non-empty tables to CSV ordered by primary key and includes metadata" do
    # Create tables
    connection.create_table(:widgets) { |t| t.string :name }
    connection.create_table(:empties) { |t| t.string :noop }

    # Insert rows out of order by id to test ORDER BY pk
    connection.execute("INSERT INTO widgets (id, name) VALUES (2, 'two')")
    connection.execute("INSERT INTO widgets (id, name) VALUES (1, 'one')")

    Dir.mktmpdir do |tmp|
      example = build_example(label: "Widgets behavior")
      out_dir = dump_database_on_failure(example, dir: tmp)

      expect(out_dir).to be_a(String)
      expect(File.directory?(out_dir)).to eq(true)

      widgets_csv = File.join(out_dir, "widgets.csv")
      empties_csv = File.join(out_dir, "empties.csv")

      expect(File.exist?(widgets_csv)).to eq(true)
      expect(File.exist?(empties_csv)).to eq(false)

      rows = CSV.read(widgets_csv)
      # Header + 2 rows
      expect(rows.length).to eq(3)
      header = rows.first
      expect(header).to include("id", "name")
      # Ensure ordering by id asc
      expect(rows[1][0]).to eq("1")
      expect(rows[2][0]).to eq("2")

      # Metadata file exists
      meta_json = File.join(out_dir, "metadata.json")
      meta_txt = File.join(out_dir, "metadata.txt")
      expect(File.exist?(meta_json) || File.exist?(meta_txt)).to eq(true)
    end
  end

  it "respects only/exclude table options" do
    connection.create_table(:alpha) { |t| t.string :v }
    connection.create_table(:beta) { |t| t.string :v }

    connection.execute("INSERT INTO alpha (id, v) VALUES (1, 'a')")
    connection.execute("INSERT INTO beta (id, v) VALUES (1, 'b')")

    Dir.mktmpdir do |tmp|
      example = build_example(label: "Filter tables")
      out_dir = dump_database_on_failure(example, dir: tmp, only: [ "alpha" ], exclude: [ "beta" ]) # both applied

      expect(File.exist?(File.join(out_dir, "alpha.csv"))).to eq(true)
      expect(File.exist?(File.join(out_dir, "beta.csv"))).to eq(false)
    end
  end

  it "does not write any files when all tables are empty" do
    connection.create_table(:empties) { |t| t.string :noop }

    Dir.mktmpdir do |tmp|
      example = build_example(label: "No data present")
      out_dir = dump_database_on_failure(example, dir: tmp, only: [ "empties" ]) # table exists but empty

      expect(out_dir).to be_nil
      # Ensure tmp dir remains empty
      expect(Dir.children(tmp)).to be_empty
    end
  end

  it "dump table to csv", :with_dump_db_on_fail do
    user = User.create(name: "John Doe", age: 10)
    city = City.create(name: "New York")
    user.cities << city
    expect(User.count).to eq(1)
    expect(City.count).to eq(1)
    expect(user.cities.count).to eq(1)
    # uncomment to test
    # expect(city.users.count).to eq(2)
  end
end
