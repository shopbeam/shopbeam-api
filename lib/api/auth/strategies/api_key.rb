module API
  module Auth
    module Strategies
      class ApiKey < Warden::Strategies::Base
        delegate :owner, to: :@auth_token

        def valid?
          api_key && signature
        end

        def authenticate!
          @auth_token = AuthToken.find_by(key: api_key)

          if @auth_token && valid_signature? && valid_referer?
            success!(owner)
          else
            fail!
          end
        end

        private

        def api_key
          params['api_key']
        end

        def signature
          params['signature']
        end

        def valid_signature?
          path_without_signature = "#{request.path}?#{Rack::Utils.build_query(request.GET.except('signature'))}"

          SignatureVerifier.verify(
            key: @auth_token.secret,
            digest: 'sha1',
            path: path_without_signature,
            signature: signature
          )
        end

        def valid_referer?
          owner.referer.nil? || Regexp.new(Regexp.escape(owner.referer)) =~ request.referer
        end
      end
    end
  end
end
