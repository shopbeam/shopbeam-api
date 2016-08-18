module API
  module V2
    module Entities
      class Address < Grape::Entity
        expose :address1
        expose :address2
        expose :city
        expose :state
        expose :zip
        expose :phoneNumber
        expose :addressType
        expose :UserId
        expose :status
      end
    end
  end
end
