# frozen_string_literal: true

require "resque/failure/multiple"
require "resque/failure/redis"

Resque::Failure::Multiple.classes = [ Resque::Failure::Redis ]
Resque::Failure.backend = Resque::Failure::Multiple

# Establish a connection between Resque and Redis
if Rails.env.production? || Rails.env.stage?
  uri = URI.parse ENV["REDIS_URL"]
  Resque.redis = Redis.new host: uri.host, port: uri.port, password: uri.password, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
else
  # we can stick here with default config
end
