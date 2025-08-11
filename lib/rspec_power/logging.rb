require "logger"
require "active_support/tagged_logging" if defined?(ActiveSupport::TaggedLogging)
require "active_support/logger"         if defined?(ActiveSupport::Logger)
require "active_record"                 if defined?(ActiveRecord)
require "active_support/log_subscriber" if defined?(ActiveSupport::LogSubscriber)

module RSpecPower
  module LoggingHelpers
      class << self
        def logger=(new_logger)
          @logger = new_logger
          global_loggables.each { |l| l.logger = new_logger }
        end

        def logger
          return @logger if defined?(@logger)
          @logger = if defined?(ActiveSupport::TaggedLogging)
            ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
          elsif defined?(ActiveSupport::Logger)
            ActiveSupport::Logger.new($stdout)
          else
            Logger.new($stdout)
          end
        end

        def global_loggables
          @global_loggables ||= []
        end

        def swap_logger(targets)
          targets.map do |target|
            old_logger = target.logger
            begin
              target.logger = logger
            rescue NoMethodError
              # Some classes expose .logger= only via class_attribute; try via Rails.logger
              # but we still continue to next target to avoid halting.
            end
            old_logger
          end
        end

        def restore_logger(old_loggers, targets)
          targets.each_with_index { |t, i| t.logger = old_loggers[i] }
        end

        def all_loggables
          base = [
            (::Rails if defined?(::Rails)),
            (::ActiveSupport::LogSubscriber if defined?(::ActiveSupport::LogSubscriber)),
            (::ActiveRecord::Base          if defined?(::ActiveRecord::Base)),
            (::ActionController::Base      if defined?(::ActionController::Base)),
            (::ActiveJob::Base             if defined?(::ActiveJob::Base)),
            (::ActionView::Base            if defined?(::ActionView::Base)),
            (::ActionMailer::Base          if defined?(::ActionMailer::Base)),
            (::ActionCable                 if defined?(::ActionCable))
          ].compact

          # Include all log subscribers for controller/action_view etc.
          if defined?(::ActiveSupport::LogSubscriber)
            ObjectSpace.each_object(Class).select { |c| c < ::ActiveSupport::LogSubscriber }.each do |subscriber|
              base << subscriber if subscriber.respond_to?(:logger)
            end
          end

          base.select { |l| l.respond_to?(:logger) }
        end

        def ar_loggables
          @ar_loggables ||= [
            ::ActiveRecord::Base,
            ::ActiveSupport::LogSubscriber
          ]
        end
      end

      def with_logging
        old = LoggingHelpers.swap_logger(LoggingHelpers.all_loggables)
        yield
      ensure
        LoggingHelpers.restore_logger(old, LoggingHelpers.all_loggables)
      end

      def with_ar_logging
        old = LoggingHelpers.swap_logger(LoggingHelpers.ar_loggables)
        yield
      ensure
        LoggingHelpers.restore_logger(old, LoggingHelpers.ar_loggables)
      end
  end
end

RSpec.shared_context "rspec_power::logging:verbose" do
  around(:each) do |ex|
    if ex.metadata[:with_log] == true || ex.metadata[:with_log] == :all ||
       ex.metadata[:with_logs] == true || ex.metadata[:with_logs] == :all
      with_logging(&ex)
    else
      ex.call
    end
  end
end

RSpec.shared_context "rspec_power::logging:active_record" do
  around(:each) do |ex|
    if ex.metadata[:with_log_ar]
      with_ar_logging(&ex)
    else
      ex.call
    end
  end
end
