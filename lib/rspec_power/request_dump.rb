module RSpecPower
  module RequestDumpHelpers
    def dump_state_after_example(example, what_items)
      items_to_dump = Array(what_items).map(&:to_sym)

      puts "\n[rspec_power] Dump after example: #{example.full_description}"

      if items_to_dump.include?(:session)
        value = fetch_session_value
        puts "[rspec_power] session: #{safe_inspect(value)}"
      end

      if items_to_dump.include?(:cookies)
        value = fetch_cookies_value
        puts "[rspec_power] cookies: #{safe_inspect(value)}"
      end

      if items_to_dump.include?(:flash)
        value = fetch_flash_value
        puts "[rspec_power] flash: #{safe_inspect(value)}"
      end

      if items_to_dump.include?(:headers)
        value = fetch_headers_value
        puts "[rspec_power] headers: #{safe_inspect(value)}"
      end
    end

    private

    def safe_inspect(value)
      case value
      when Hash
        begin
          value.transform_keys { |k| k.to_s }.inspect
        rescue
          value.inspect
        end
      else
        value.inspect
      end
    end

    def fetch_session_value
      if respond_to?(:session)
        coerce_to_hash(session)
      elsif defined?(request) && request.respond_to?(:session)
        coerce_to_hash(request.session)
      elsif defined?(controller) && controller.respond_to?(:session)
        coerce_to_hash(controller.session)
      else
        :unavailable
      end
    rescue => e
      "unavailable (#{e.class}: #{e.message})"
    end

    def fetch_cookies_value
      if respond_to?(:cookies)
        coerce_to_hash(cookies)
      elsif defined?(request) && request.respond_to?(:cookie_jar)
        coerce_to_hash(request.cookie_jar)
      elsif defined?(response) && response.respond_to?(:cookies)
        coerce_to_hash(response.cookies)
      else
        :unavailable
      end
    rescue => e
      "unavailable (#{e.class}: #{e.message})"
    end

    def fetch_flash_value
      if respond_to?(:flash)
        coerce_to_hash(flash)
      elsif defined?(controller) && controller.respond_to?(:flash)
        coerce_to_hash(controller.flash)
      else
        :unavailable
      end
    rescue => e
      "unavailable (#{e.class}: #{e.message})"
    end

    def fetch_headers_value
      if defined?(request) && request.respond_to?(:headers)
        coerce_to_hash(request.headers)
      elsif defined?(response) && response.respond_to?(:request) && response.request.respond_to?(:headers)
        coerce_to_hash(response.request.headers)
      elsif defined?(controller) && controller.respond_to?(:request) && controller.request.respond_to?(:headers)
        coerce_to_hash(controller.request.headers)
      else
        :unavailable
      end
    rescue => e
      "unavailable (#{e.class}: #{e.message})"
    end

    def coerce_to_hash(obj)
      return {} if obj.nil?
      return obj.to_hash if obj.respond_to?(:to_hash)
      return obj.to_h if obj.respond_to?(:to_h)
      if defined?(ActionDispatch::Request::Session) && obj.is_a?(ActionDispatch::Request::Session)
        return obj.to_hash
      end
      obj.inspect
    end
  end
end

RSpec.shared_context "rspec_power::request_dump:after" do
  include RSpecPower::RequestDumpHelpers

  after(:each) do |example|
    dump_meta = example.metadata[:with_request_dump]
    next unless dump_meta

    what = if dump_meta.is_a?(Hash) && dump_meta[:what]
      dump_meta[:what]
    else
      [ :session, :cookies, :flash, :headers ]
    end

    dump_state_after_example(example, what)
  end
end
