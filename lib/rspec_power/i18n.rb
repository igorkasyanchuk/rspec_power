module RSpecPower
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

RSpec.shared_context "rspec_power::i18n:dynamic" do
  around(:each) do |example|
    if example.metadata.key?(:with_locale)
      with_locale(example.metadata[:with_locale]) { example.run }
    else
      example.run
    end
  end
end
