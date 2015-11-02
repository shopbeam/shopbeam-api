module API
  module Auth
    module Strategies
      class Password < Warden::Strategies::Base
        def valid?
          email || password
        end

        def authenticate!
          consumer = Consumer.find_by(email: email)

          if consumer && consumer.authenticate(password)
            consumer.access_token = consumer.access_tokens.create!
            success!(consumer)
          else
            fail!
          end
        end

        private

        def email
          params['email']
        end

        def password
          params['password']
        end
      end
    end
  end
end
