module API
  module V2
    module Entities
      class Publisher < Grape::Entity
        expose :apiKey
        expose :email
        expose :firstName
        expose :lastName
        expose :commission
      end
    end
  end
end
