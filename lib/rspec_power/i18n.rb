require_relative "rails/i18n_helpers"

RSpec.shared_context "rspec_power::i18n:dynamic" do
  around(:each) do |example|
    if example.metadata.key?(:with_locale)
      with_locale(example.metadata[:with_locale]) { example.run }
    else
      example.run
    end
  end
end
