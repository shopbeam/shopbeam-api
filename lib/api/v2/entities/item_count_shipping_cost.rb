module API
  module V2
    module Entities
      class ItemCountShippingCost < Grape::Entity
        expose :itemCount, :shippingPrice
      end
    end
  end
end
