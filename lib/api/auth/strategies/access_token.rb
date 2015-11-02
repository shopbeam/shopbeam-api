module API
  module Auth
    module Strategies
      class AccessToken < Warden::Strategies::Base
        delegate :consumer, to: :@access_token

        def valid?
          fingerprint && token
        end

        def authenticate!
          @access_token = ::AccessToken.find_by(fingerprint: fingerprint)

          case
          when @access_token.nil?
            fail!
          when valid_token?
            @access_token.regenerate!
            login!
          when valid_prev_token?
            @access_token.touch
            login!
          else
            fail!
          end
        end

        private

        def fingerprint
          env['HTTP_X_AUTH_FINGERPRINT']
        end

        def token
          env['HTTP_X_AUTH_TOKEN']
        end

        def valid_token?
          !@access_token.expired? &&
          matches?(@access_token.token)
        end

        def valid_prev_token?
          @access_token.prev_token? &&
          @access_token.reusable? &&
          matches?(@access_token.prev_token)
        end

        def matches?(value)
          ActiveSupport::SecurityUtils.secure_compare(token, value)
        end

        def login!
          consumer.delete_expired_tokens
          consumer.access_token = @access_token
          success!(consumer)
        end
      end
    end
  end
end
