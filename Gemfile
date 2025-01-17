# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.1.4"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.4"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.4"
gem "scenic", "~> 1.5"
# Use Puma as the app server
gem 'puma', '< 6'
# Use SCSS for stylesheets
gem "sassc-rails", "~> 2.1"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem "bootstrap", "~> 4.3.1"
gem "bootstrap_form", "~> 4.5.0"
gem "font-awesome-rails"
gem "jquery-rails"
gem "rails-i18n"
gem "simple_calendar", "~> 2.0"
gem "net-imap"
gem "net-pop"
gem "net-smtp"

gem "memoist"
gem "cocoon"

gem "audited", "~> 4.9"
gem "discard", "~> 1.0"
gem "devise", "~> 4.8"
gem "devise-i18n"
gem "devise-bootstrap-views"
gem "devise_invitable", "~> 2.0.0"
gem "doorkeeper", "~> 5.5.4"
gem 'doorkeeper-openid_connect'
gem "pundit", "~> 2.2.0"
gem 'newrelic_rpm'

gem "azure-storage-blob", "~> 2.0",  require: false

gem "money-rails", "~>1.12"

# Geo libraries
gem "rgeo"
gem "rgeo-geojson"

gem "kaminari"

gem "activerecord-import"
gem "resque", "~> 2.0.0"

# Excel export
gem "caxlsx", "~> 3.1"
gem "caxlsx_rails"

gem "trestle"
gem "trestle-auth"

gem "select2-rails"
gem "date_validator"

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
gem "jb"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "capybara"
  gem "capybara-screenshot"
  gem "factory_bot_rails"
  gem "pundit-matchers", "~> 1.6.0"
  gem "rails-controller-testing"
  gem "rspec-benchmark", ">= 0.4"
  gem "rspec-rails", "~> 4.0.2"
  gem "rspec-its", "~> 1.2.0"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "brakeman"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "listen"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# Reduces boot times through caching; configured in config/boot.rb
gem "bootsnap", require: false
