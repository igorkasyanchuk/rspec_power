require "logger"
require "active_support/tagged_logging" if defined?(ActiveSupport::TaggedLogging)
require "active_support/logger"         if defined?(ActiveSupport::Logger)
require "active_record"                 if defined?(ActiveRecord)
require "active_support/log_subscriber" if defined?(ActiveSupport::LogSubscriber)

module RspecPower
  module Rails
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
          targets.map { |t| old = t.logger; t.logger = logger; old }
        end

        def restore_logger(old_loggers, targets)
          targets.each_with_index { |t, i| t.logger = old_loggers[i] }
        end

        def all_loggables
          @all_loggables ||= [
            ::ActiveSupport::LogSubscriber,
            (::Rails if defined?(::Rails)),
            (defined?(::ActiveRecord::Base) && ::ActiveRecord::Base),
            (defined?(::ActiveJob::Base)    && ::ActiveJob::Base),
            (defined?(::ActionView::Base)   && ::ActionView::Base),
            (defined?(::ActionMailer::Base) && ::ActionMailer::Base),
            (defined?(::ActionCable)        && ::ActionCable)
          ].compact.select { |l| l.respond_to?(:logger) }
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
end
