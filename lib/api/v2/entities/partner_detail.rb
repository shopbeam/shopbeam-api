module API
  module V2
    module Entities
      class PartnerDetail < Grape::Entity
        expose :state, :zip, :shippingType, :salesTax, :freeShippingAbove, :siteWideDiscount
        expose :shipping_items, using: API::V2::Entities::ItemCountShippingCost, as: :shippingItems
      end
    end
  end
end
