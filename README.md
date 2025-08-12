# RSpec Power 🔥

[![Gem Version](https://badge.fury.io/rb/rspec_power.svg)](https://badge.fury.io/rb/rspec_power)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![RailsJazz](https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/my_other.svg?raw=true)](https://www.railsjazz.com)

A powerful collection of RSpec helpers and utilities that supercharge your Rails testing experience! 🚀

## ✨ Features

| Feature | Summary | Usage |
| --- | --- | --- |
| [🔍 Enhanced Logging](#-enhanced-logging) | Capture and control Rails logs; ActiveRecord-only option | `:with_log`, `:with_logs`, `:with_log_ar`, `with_logging`, `with_ar_logging` |
| [🌍 Environment Management](#-environment-variable-management) | Override environment variables with auto-restore | `:with_env`, `with_test_env` |
| [🌐 I18n Testing](#-internationalization-i18n-testing) | Switch locales and assert translations | `:with_locale`, `with_locale` |
| [⏰ Time Manipulation](#-time-manipulation) | Freeze/travel time for deterministic tests | `:with_time_freeze` |
| [🕘 Time Zone Control](#-time-manipulation) | Run examples in a specific time zone | `:with_time_zone` |
| [⚡ Performance Budgeting](#-performance-budgeting) | Enforce maximum example execution time | `with_maximum_execution_time`, `:with_maximum_execution_time` |
| [📏 Benchmarking](#-benchmarking) | Run examples multiple times and summarize | `with_benchmark: { runs: N }` |
| [🏗️ CI-only Guards](#-shared-contexts) | Conditionally run or skip on CI | `:with_ci_only`, `:with_skip_ci` |
| [🧪 SQL Guards](#-shared-contexts) | Ensure no SQL or require at least one | `expect_no_sql`, `:with_no_sql_queries`, `expect_sql`, `:with_sql_queries` |
| [💾 Request Dump](#-request-dump) | Dump session, cookies, flash, headers after each example | `:with_request_dump`, `with_request_dump: { what: [:session, :cookies, :flash, :headers] }` |
| [🗄️ DB Dump on Failure](#-db-dump-on-failure) | Dump DB tables to CSV when an example fails | `:with_dump_db_on_fail`, `with_dump_db_on_fail: { tables: [...], except: [...] }` |

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem "rspec_power", require: false
end
```

And then execute:

```bash
bundle install
```

## 🚀 Quick Start

The gem automatically configures itself when required. Just add it to your Gemfile.

## 📚 Usage Examples

### 🔍 Enhanced Logging

Capture all Rails logs during specific tests:

```ruby
RSpec.describe User, :with_log do
  it "creates a user with logging" do
    # All Rails logs will be captured and displayed
    user = User.create!(name: "John Doe", email: "john@example.com")
    expect(user).to be_persisted
  end
end
```

or for specific tests (alias `:with_logs` is also supported):

```ruby
RSpec.describe User do
  it "creates a user with logging", :with_log do
    # All Rails logs will be captured and displayed
    user = User.create!(name: "John Doe", email: "john@example.com")
    expect(user).to be_persisted
  end
end
```

Capture only ActiveRecord logs:

```ruby
RSpec.describe User, :with_log_ar do
  it "shows SQL queries" do
    # Only ActiveRecord logs will be captured
    users = User.where(active: true).includes(:profile)
    expect(users).to be_any
  end
end
```

Manual logging control:

```ruby
RSpec.describe User do
  it "manually controls logging" do
    with_logging do
      # All Rails logs captured here
      User.create!(name: "Jane")
    end
    # Logging back to normal here
  end

  it "captures only ActiveRecord logs" do
    with_ar_logging do
      # Only ActiveRecord logs captured here
      User.count
    end
  end
end
```

Ensure a block performs no SQL:

```ruby
RSpec.describe CacheWarmup do
  it "does not hit the DB" do
    expect_no_sql do
      CacheWarmup.build_in_memory!
    end
  end
end
```

Require that a block performs at least one SQL statement:

```ruby
RSpec.describe MigrationChecker do
  it "touches the DB" do
    expect_sql do
      ActiveRecord::Base.connection.execute("SELECT 1")
    end
  end
end
```

Or tag an example/group to enforce or require queries automatically:

```ruby
RSpec.describe CacheWarmup, :with_no_sql_queries do
  it "builds entirely in memory" do
    CacheWarmup.build_in_memory!
  end
end

RSpec.describe MigrationChecker, :with_sql_queries do
  it "must hit the DB at least once" do
    ActiveRecord::Base.connection.execute("SELECT 1")
  end
end

# (Only the correct tags are supported)
```

### 🌍 Environment Variable Management

Override environment variables for specific tests:

```ruby
RSpec.describe PaymentService, :with_env do
  it "uses test API key", with_env: { 'STRIPE_API_KEY' => 'test_key_123' } do
    service = PaymentService.new
    expect(service.api_key).to eq('test_key_123')
  end

  it "handles multiple env vars", with_env: {
    'RAILS_ENV' => 'test',
    'DATABASE_URL' => 'postgresql://localhost/test_db'
  } do
    expect(ENV['RAILS_ENV']).to eq('test')
    expect(ENV['DATABASE_URL']).to eq('postgresql://localhost/test_db')
  end
end
```

Manual environment control:

```ruby
RSpec.describe ConfigService do
  it "manually overrides environment" do
    with_test_env('API_URL' => 'https://api.test.com') do
      expect(ENV['API_URL']).to eq('https://api.test.com')
    end
    # Environment restored automatically
  end
end
```

### 🌐 Internationalization (I18n) Testing

Test your application in different locales:

```ruby
RSpec.describe User, :with_locale do
  it "displays name in English", with_locale: :en do
    user = User.new(name: "John")
    expect(user.greeting).to eq("Hello, John!")
  end

  it "displays name in Spanish", with_locale: :es do
    user = User.new(name: "Juan")
    expect(user.greeting).to eq("¡Hola, Juan!")
  end

  it "displays name in French", with_locale: :fr do
    user = User.new(name: "Jean")
    expect(user.greeting).to eq("Bonjour, Jean!")
  end
end
```

Manual locale control:

```ruby
RSpec.describe LocalizationHelper do
  it "manually changes locale" do
    with_locale(:de) do
      expect(I18n.locale).to eq(:de)
      expect(t('hello')).to eq('Hallo')
    end
    # Locale restored automatically
  end
end
```

### ⏰ Time Manipulation

Freeze time for consistent test results:

```ruby
RSpec.describe Order, :with_time_freeze do
  it "creates order with current timestamp", with_time_freeze: "2024-01-15 10:30:00" do
    order = Order.create!(amount: 100)
    expect(order.created_at).to eq(Time.parse("2024-01-15 10:30:00"))
  end

  it "handles time-sensitive logic", with_time_freeze: Time.new(2024, 12, 25, 12, 0, 0) do
    expect(Time.current).to eq(Time.new(2024, 12, 25, 12, 0, 0))
    # Test Christmas-specific logic
  end
end
```

Run tests in a specific time zone:

```ruby
RSpec.describe ReportGenerator, :with_time_zone do
  it "builds report in US Pacific", with_time_zone: "Pacific Time (US & Canada)" do
    # The block runs with Time.zone set to Pacific
    expect(Time.zone.name).to eq("Pacific Time (US & Canada)")
  end
end
```

Manual time control:

```ruby
RSpec.describe TimeService do
  it "manually travels through time" do
    travel_to(Time.new(2024, 6, 15, 14, 30, 0)) do
      expect(Time.current).to eq(Time.new(2024, 6, 15, 14, 30, 0))
    end
    # Time restored automatically
  end
end
```

### ⚡ Performance Budgeting

Limit example duration:

```ruby
RSpec.describe Importer do
  it "is fast enough" do
    with_maximum_execution_time(50) do
      Importer.run!
    end
  end
end
```

Or via metadata:

```ruby
RSpec.describe Importer, with_maximum_execution_time: 100 do
  it "completes quickly" do
    Importer.run!
  end
end
```

### 📏 Benchmarking

Benchmark entire examples via metadata and get a suite summary:

```ruby
RSpec.describe Parser, with_benchmark: { runs: 10 } do
  it "parses quickly" do
    Parser.parse!(payload)
  end
end
```

The example is executed multiple times (runs) and the average/min/max times are printed after the suite.

### 💾 Request Dump

Dump request-related state after each example to help debug request specs.

Supported items:

- `:session`
- `:cookies`
- `:flash`
- `:headers`

Enable for an example or group and choose what to dump:

```ruby
RSpec.describe "Users API", type: :request do
  it "dumps everything by default", :with_request_dump do
    post "/set_state"
    expect(response).to be_successful
  end

  it "dumps only session and cookies",
     with_request_dump: { what: [:session, :cookies] } do
    post "/set_state"
    expect(response).to be_successful
  end
end
```

Example output:

```

### 🗄️ DB Dump on Failure

Dump database state to CSV files when an example fails. Useful to inspect exactly what data led to the failure.

By default, all non-empty tables are dumped (excluding `schema_migrations` and `ar_internal_metadata`). Each table is exported to a separate CSV file, ordered by primary key if present. Files are written under `tmp/rspec_power/db_failures/<timestamp>_<spec-name>/` and include a `metadata.json` with the spec name.

Enable for an example or group:

```ruby
RSpec.describe User, :with_dump_db_on_fail do
  it "creates a user" do
    # ...
  end
end
```

Customize which tables to include/exclude and output directory:

```ruby
RSpec.describe Report, with_dump_db_on_fail: { tables: ["users", "accounts"], except: ["accounts"], dir: Rails.root.join("tmp", "db_dumps").to_s } do
  it "fails and dumps only selected tables" do
    # ...
  end
end
```

Options:

- `tables` / `only`: specify a whitelist of tables to dump
- `except` / `exclude`: tables to skip
- `dir`: base output directory (default: `tmp/rspec_power/db_failures`)
[rspec_power] Dump after example: Users API dumps everything by default
[rspec_power] session: {"user_id"=>42}
[rspec_power] cookies: {"hello"=>"world"}
[rspec_power] flash: {"notice"=>"done"}
[rspec_power] headers: { ... }
```

## 🎯 Shared Contexts

The gem provides several pre-configured shared contexts:

- `rspec_power::logging:verbose` - Enables verbose logging for tests with `:with_log` metadata
- `rspec_power::logging:active_record` - Enables ActiveRecord logging for tests with `:with_log_ar` metadata
- `rspec_power::env:override` - Automatically handles environment variable overrides
- `rspec_power::i18n:dynamic` - Manages locale changes for tests with `:with_locale` metadata
- `rspec_power::time:freeze` - Handles time freezing for tests with `:with_time_freeze` metadata
- `rspec_power::time:zone` - Executes examples in a given time zone with `:with_time_zone` metadata
- `rspec_power::ci:only` - Runs examples only in CI when tagged with `:with_ci_only`
- `rspec_power::ci:skip` - Skips examples in CI when tagged with `:with_skip_ci`
- `rspec_power::request_dump:after` - Dumps selected request state after each example with `:with_request_dump` metadata

## 🔧 Configuration

The gem automatically configures itself, but you can customize the behavior:

```ruby
# In spec_helper.rb or rails_helper.rb
RSpec.configure do |config|
  # Customize logging behavior
  config.include RSpecPower::Rails::LoggingHelpers
  config.include_context "rspec_power::logging:verbose", with_log: true
  config.include_context "rspec_power::logging:verbose", with_logs: true
  config.include_context "rspec_power::logging:active_record", with_log_ar: true

  # Customize environment helpers
  config.include RSpecPower::Rails::EnvHelpers
  config.include_context "rspec_power::env:override", :with_env

  # Customize I18n helpers
  config.include RSpecPower::Rails::I18nHelpers
  config.include_context "rspec_power::i18n:dynamic", :with_locale

  # Customize time helpers
  config.include RSpecPower::Rails::TimeHelpers
  config.include_context "rspec_power::time:freeze", :with_time_freeze
  config.include_context "rspec_power::time:zone", :with_time_zone

  # CI-only guards
  config.include_context "rspec_power::ci:only", :with_ci_only
  config.include_context "rspec_power::ci:skip", :with_skip_ci

  # Request dump helpers (session/cookies/flash/headers)
  config.include RSpecPower::RequestDumpHelpers
  config.include_context "rspec_power::request_dump:after", :with_request_dump
end
```

### CI detection via environment variable

The CI-only guards rely on the `CI` environment variable:

- Considered CI when `ENV["CI"]` is set to any non-empty value other than `"false"` or `"0"` (case-insensitive).
- Considered non-CI when `ENV["CI"]` is unset/empty, `"false"`, or `"0"`.

Examples:

```bash
# Run a single file as if on CI
CI=true bundle exec rspec spec/path/to/file_spec.rb

# Also treated as CI
CI=1 bundle exec rspec

# Explicitly run as non-CI
CI=0 bundle exec rspec
```

## 🧪 Testing

Run the test suite:

```bash
bundle exec rspec
```

## Linter

```bash
bundle exec rubocop
```

To fix most issues, run:

```bash
bundle exec rubocop -A
```


## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📖 Credits

Code for logging was extracted from [test-prof](https://github.com/test-prof/test-prof) gem.

## 📄 License

This project is licensed under the MIT License - see the [MIT-LICENSE](MIT-LICENSE) file for details.

---

[<img src="https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/more_gems.png?raw=true"
/>](https://www.railsjazz.com/?utm_source=github&utm_medium=bottom&utm_campaign=rails_performance)

[!["Buy Me A Coffee"](https://github.com/igorkasyanchuk/get-smart/blob/main/docs/snapshot-bmc-button.png?raw=true)](https://buymeacoffee.com/igorkasyanchuk)

Made with ❤️ for the Rails testing community!
