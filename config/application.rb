require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlowReport
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.i18n.available_locales = [:de, :en]
    config.i18n.default_locale = :de

    config.time_zone = 'Bern'
    config.active_record.default_timezone = :utc

    # Use resqueue as Job Queue Processor
    config.active_job.queue_adapter = :resque

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address:              'smtp.sendgrid.net',
        port:                 587,
        domain:               'fahrzeit.ch',
        user_name:            'apikey',
        password:             ENV['MAIL_PW'],
        authentication:       'plain',
        enable_starttls_auto: true
    }

    config.autoload_paths << Rails.root.join('lib')
  end
end
