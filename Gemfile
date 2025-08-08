source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.7"

# Rails and core gems
gem "rails", "~> 8.0.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# Authentication and Authorization
gem "bcrypt", "~> 3.1.7"
gem "jwt", "~> 2.7"

# API and Serialization
gem "jbuilder", "~> 2.11"
gem "rack-cors"
gem "jsonapi-serializer", "~> 2.2"

# Background Jobs
gem "sidekiq", "~> 7.0"
gem "redis", "~> 5.0"

# Payment Processing
gem "stripe", "~> 9.0"

# Email and Notifications
gem "mailgun-ruby", "~> 1.2"
gem "premailer-rails", "~> 1.11"

# File Upload and Storage
gem "aws-sdk-s3", require: false
gem "image_processing", "~> 1.2"

# Utilities
gem "money-rails", "~> 1.15"
gem "friendly_id", "~> 5.4"
gem "kaminari", "~> 1.2"
gem "ransack", "~> 4.1"

# Security and Rate Limiting
gem "rack-attack", "~> 6.6"
gem "brakeman", "~> 7.1"

# Development and Testing
group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "shoulda-matchers", "~> 5.1"
  gem "database_cleaner-active_record", "~> 2.1"
  gem "vcr", "~> 6.1"
  gem "webmock", "~> 3.18"
  gem "dotenv-rails", "~> 2.8"
  gem "rubocop", "~> 1.50"
  gem "rubocop-rails", "~> 2.20"
  gem "rubocop-rspec", "~> 2.20"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "rack-mini-profiler", "~> 3.1"
  gem "listen", "~> 3.3"
  gem "spring"
  gem "letter_opener", "~> 1.8"
end

group :test do
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver", ">= 4.0.0.rc1"
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# and uncomment the following line in Gemfile.
# gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
