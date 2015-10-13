# If fakeredis is loaded, use it explicitly
if defined?(Redis::Connection::Memory)
  Sidekiq.configure_client do |config|
    config.redis = { :driver => Redis::Connection::Memory }
  end

  Sidekiq.configure_server do |config|
    config.redis = { :driver => Redis::Connection::Memory }
  end
end
