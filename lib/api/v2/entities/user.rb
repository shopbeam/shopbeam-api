module API
  module V2
    module Entities
      class User < Grape::Entity
        expose :email
        expose :password
        expose :firstName
        expose :lastName
        expose :apiKey
        expose :status
        expose :role, as: :roleToAdd

        private

        def role
          'Guest'
        end
      end
    end
  end
end
