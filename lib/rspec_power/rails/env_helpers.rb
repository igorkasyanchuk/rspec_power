module RspecPower
  module Rails
    module EnvHelpers
      def with_test_env(overrides = {})
        old_values = overrides.each_with_object({}) do |(key, _), memo|
          memo[key] = ENV.key?(key) ? ENV[key] : :__undefined__
        end

        # apply overrides (stringify keys just in case)
        overrides.each { |k, v| ENV[k.to_s] = v }

        yield
      ensure
        # restore old values
        old_values.each do |key, val|
          if val == :__undefined__
            ENV.delete(key)
          else
            ENV[key] = val
          end
        end
      end
    end
  end
end
