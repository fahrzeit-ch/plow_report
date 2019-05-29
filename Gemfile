source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
gem 'sprockets', '~> 3.7.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
gem "scenic", '~> 1.5'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'bootstrap', '~> 4.3.1'
gem 'bootstrap_form',
    git: 'https://github.com/bootstrap-ruby/bootstrap_form.git',
    branch: 'master'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'rails-i18n'
gem 'simple_calendar', '~> 2.0'

gem 'audited', '~> 4.7'
gem 'devise'
gem 'devise-bootstrap-views'
gem 'devise_invitable', '~> 1.7.0'
gem 'doorkeeper', '~> 5.1.0'
gem 'pundit', '~> 1.1.0'
gem 'rollbar'

gem 'money-rails', '~>1.12'

gem 'kaminari'

gem 'activerecord-import'
gem 'resque', '~> 2.0.0'
gem 'resque-rollbar'

# Excel export
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'

gem 'trestle'
gem 'trestle-auth'

gem 'select2-rails'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'factory_bot_rails'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'rails-controller-testing'
  gem 'rspec-benchmark', '>= 0.4'
  gem 'rspec-rails', '>= 3.7.2', '< 4.0'
  gem 'rspec-its', '~> 1.2.0'
  gem 'rubocop'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
