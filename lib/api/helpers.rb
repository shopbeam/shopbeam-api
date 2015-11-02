module API
  module Helpers
    def warden
      env['warden']
    end

    def authenticate_client!
      warden.authenticate!(scope: :client)
    end

    def authenticate_service!
      warden.authenticate!(scope: :service)
    end

    def authenticate_consumer!
      warden.authenticate!(scope: :consumer)
      set_auth_headers
    end

    def current_client
      warden.user(:client)
    end

    def current_service
      warden.user(:service)
    end

    def current_consumer
      warden.user(:consumer)
    end

    def set_consumer(consumer)
      warden.set_user(consumer, scope: :consumer, store: false)
      set_auth_headers
    end

    private

    def set_auth_headers
      return unless current_consumer

      header 'X-Auth-Fingerprint', current_consumer.fingerprint
      header 'X-Auth-Token',       current_consumer.token
      header 'X-Auth-Expires',     current_consumer.expires_at.strftime('%s')
    end
  end
end
