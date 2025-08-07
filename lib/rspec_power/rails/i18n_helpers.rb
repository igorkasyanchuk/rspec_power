module RspecPower
  module Rails
    module I18nHelpers
      def with_locale(locale)
        old = I18n.locale
        I18n.locale = locale
        yield
      ensure
        I18n.locale = old
      end
    end
  end
end
