source "https://rubygems.org"

ruby "3.1.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# ArcEx Gems:
gem 'devise'
gem 'jsonapi-serializer'
gem 'bootstrap-email'
gem 'sassc'
gem 'sassc-rails', group: :assets
gem 'hashids'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Email previewing in browser:
  gem 'letter_opener'
  gem 'letter_opener_web'

  #? TODO: Implement RSpec with these helper gems later:
  # RSpec (runtime)
  # gem 'factory_bot_rails'
  gem 'faker'
  gem 'ffaker'

  # Environment management (eventually replace with AWS Credentials Manager / similar after MVP):
  gem 'dotenv'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]

  # Useful for debugging:
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  # Error reporting for development:
  gem 'better_errors'
  gem 'binding_of_caller'

  #? TODO: Implement RSpec later on:
  # # RSpec
  # gem 'rspec-rails'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  #? TODO: Again, implement these two blocks of dependencies with RSpec later on:
  # # Coverage
  # gem 'simplecov', require: false
  # gem 'simplecov-lcov'

  # # Smart testing
  # gem 'database_cleaner'
end
