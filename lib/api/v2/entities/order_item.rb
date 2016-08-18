module API
  module V2
    module Entities
      class OrderItem < Grape::Entity
        expose :id
        expose :quantity
        expose :listPriceCents
        expose :salePriceCents
        expose :commissionCents
        expose :OrderId, as: :orderId
        expose :apiKey
        expose :widgetUuid
        expose :sourceUrl
        expose :VariantId, as: :variantId
        expose :createdAt
        expose :updatedAt

        expose :status do |instance|
          ::OrderItem.statuses[instance.status]
        end
      end
    end
  end
end
