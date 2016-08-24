module API
  module V2
    module Entities
      class Order < Grape::Entity
        expose :order do
          expose :order_items, using: API::V2::Entities::OrderItem, as: :orderItems
          expose :id
          expose :shippingCents
          expose :taxCents
          expose :orderTotalCents
          expose :notes
          expose :appliedCommissionCents
          expose :UserId, as: :userId
          expose :ShippingAddressId, as: :shippingAddressId
          expose :BillingAddressId, as: :billingAddressId
          expose :PaymentId, as: :paymentId
          expose :shareWithPublisher
          expose :apiKey
          expose :sourceUrl

          expose :status do |instance|
            ::Order.statuses[instance.status]
          end

          expose :dequeuedAt
          expose :createdAt
          expose :updatedAt
          expose :theme
          expose :shipping_address, using: API::V2::Entities::Address, as: :shippingAddress
          expose :billing_address, using: API::V2::Entities::Address, as: :billingAddress
          expose :payment, using: API::V2::Entities::Payment, as: :paymentData
          expose :user, using: API::V2::Entities::User
          expose :publishers
        end

        private

        def publishers
          options[:publishers]
        end
      end
    end
  end
end
