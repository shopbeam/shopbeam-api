module API
  module V2
    module Entities
      class ItemCountShippingCost < Grape::Entity
        expose :itemCount
        expose :shippingPrice
      end
    end
  end
end
