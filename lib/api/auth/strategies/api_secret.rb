module API
  module Auth
    module Strategies
      class ApiSecret < Warden::Strategies::Base
        def valid?
          api_key && api_secret
        end

        def authenticate!
          @auth_token = AuthToken.find_by(key: api_key)

          if @auth_token && valid_secret?
            success!(@auth_token.owner)
          else
            fail!
          end
        end

        private

        def api_key
          params['api_key']
        end

        def api_secret
          params['api_secret']
        end

        def valid_secret?
          ActiveSupport::SecurityUtils.secure_compare(
            @auth_token.secret,
            api_secret
          )
        end
      end
    end
  end
end
