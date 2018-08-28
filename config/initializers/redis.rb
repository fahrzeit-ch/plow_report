require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque/rollbar'

Resque::Failure::Multiple.classes = [ Resque::Failure::Redis, Resque::Failure::Rollbar ]
Resque::Failure.backend = Resque::Failure::Multiple

# Establish a connection between Resque and Redis
if Rails.env == "production"
  uri = URI.parse ENV["REDIS_URL"]
  Resque.redis = Redis.new host:uri.host, port:uri.port, password:uri.password
else
  # we can stick here with default config
end