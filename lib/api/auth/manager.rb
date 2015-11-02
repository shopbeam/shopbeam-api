module API
  module Auth
    module Manager
      extend ActiveSupport::Concern

      included do
        use Warden::Manager do |manager|
          manager.failure_app = ->(env) { raise API::Errors::UnauthorizedError }

          manager.scope_defaults :client, store: false, strategies: [:api_key]
          manager.scope_defaults :service, store: false, strategies: [:api_secret]
          manager.scope_defaults :consumer, store: false, strategies: [:password, :access_token]
        end

        Warden::Strategies.add :api_key, API::Auth::Strategies::ApiKey
        Warden::Strategies.add :api_secret, API::Auth::Strategies::ApiSecret
        Warden::Strategies.add :password, API::Auth::Strategies::Password
        Warden::Strategies.add :access_token, API::Auth::Strategies::AccessToken
      end
    end
  end
end
