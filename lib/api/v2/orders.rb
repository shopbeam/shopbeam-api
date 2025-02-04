module API
  module V2
    class Orders < Grape::API
      include Validations

      desc 'Process order'
      params do
        requires :payment,            type: Hash do
          requires :type,             type: Integer
          requires :number,           type: String
          requires :expirationMonth,  type: Integer
          requires :expirationYear,   type: Integer
          requires :name,             type: String
          requires :cvv,              type: String
          requires :billingAddress,   type: Hash do
            requires :phoneNumber,    type: String
            requires :address1,       type: String
            requires :address2,       type: String
            requires :city,           type: String
            requires :state,          type: String
            requires :zip,            type: String
          end
        end
        requires :user,               type: Hash do
          requires :email,            type: String
          requires :password,         type: String
          requires :firstName,        type: String
          requires :middleName,       type: String
          requires :lastName,         type: String
        end
        requires :shippingAddress,    type: Hash do
          requires :phoneNumber,      type: String
          requires :address1,         type: String
          requires :address2,         type: String
          requires :city,             type: String
          requires :state,            type: String
          requires :zip,              type: String
        end
        requires :items,              type: Array, allow_blank: false, validate_prices: true do
          requires :listPriceCents,   type: Integer
          requires :salePriceCents,   type: Integer
          requires :variantId,        type: Integer
          requires :quantity,         type: Integer
          requires :sourceUrl,        type: String
          requires :apiKey,           type: String
          requires :widgetUuid,       type: String
        end
        requires :shippingCents,      type: Integer
        requires :taxCents,           type: Integer
        optional :notes,              type: String
        requires :shareWithPublisher, type: Boolean
        requires :apiKey,             type: String
        requires :sourceUrl,          type: String
        optional :theme,              type: String
      end
      resource :orders do
        post do
          # TODO: below looks REALLY messy, extract into service object
          user, order, publishers = nil, nil, []

          ActiveRecord::Base.transaction do
            user = declared_params[:user]
            user_record = User.create_with(first_name: user[:firstName], last_name: user[:lastName],
                                           api_key: SecureRandom.uuid, status: 1, createdAt: Time.now,
                                           updatedAt: Time.now, password: user[:password])
                              .find_or_create_by!(email: user[:email])

            payment = declared_params[:payment]
            payment_record = Payment.create!(name: payment[:name], UserId: user_record.id, number: payment[:number], cvv: payment[:cvv],
                                             expirationYear: payment[:expirationYear], expirationMonth: payment[:expirationMonth],
                                             type: payment[:type], createdAt: Time.now, updatedAt: Time.now, status: 1)

            shipping = declared_params[:shippingAddress]
            shipping_addr = ShippingAddress.create!(address1: shipping[:address1], address2: shipping[:address2],
                                                    city: shipping[:city], state: shipping[:state], zip: shipping[:zip],
                                                    phone_number: shipping[:phoneNumber], status: 1, address_type: 1, user_id: user_record.id,
                                                    createdAt: Time.now, updatedAt: Time.now)

            billing = payment[:billingAddress]
            billing_addr = BillingAddress.create!(address1: billing[:address1], address2: billing[:address2],
                                                  city: billing[:city], state: billing[:state], zip: billing[:zip],
                                                  phone_number: billing[:phoneNumber], status: 1, address_type: 2, user_id: user_record.id,
                                                  createdAt: Time.now, updatedAt: Time.now)

            order_status = billing_addr.zip == '00000' ? :test : :pending
            order = Order.create!(shippingCents: declared_params[:shippingCents] || 0, taxCents: declared_params[:taxCents],
                                  orderTotalCents: 0, notes: declared_params[:notes], appliedCommissionCents: 0,
                                  status: order_status, ShippingAddressId: shipping_addr.id, BillingAddressId: billing_addr.id,
                                  UserId: user_record.id, PaymentId: payment_record.id, shareWithPublisher: declared_params[:shareWithPublisher],
                                  apiKey: declared_params[:apiKey], sourceUrl: declared_params[:sourceUrl], theme: declared_params[:theme],
                                  createdAt: Time.now, updatedAt: Time.now)
            order_items = []
            with_param(:items) do |items|
              items.each do |item|
                variant = Variant.find(item[:variantId])
                order_items << OrderItem.create!(OrderId: order.id, VariantId: item[:variantId], quantity: item[:quantity], listPriceCents: variant.list_price_cents,
                                                 status: order_status, salePriceCents: variant.sale_price_cents, sourceUrl: item[:sourceUrl], apiKey: item[:apiKey],
                                                 widgetUuid: item[:widgetUuid], createdAt: Time.now, updatedAt: Time.now, commissionCents: variant.commission_cents(item[:quantity]))
              end
            end
            order.update!(
              orderTotalCents: order_items.sum(&:total_price_cents),
              appliedCommissionCents: order_items.sum(&:commission_cents)
            )
            order_items.group_by(&:api_key).each do |api_key, items|
              publisher_user = User.find_by!(api_key: api_key)
              commission = items.sum(&:commission_cents)
              publisher_user.update_attributes!(
                pendingCommissionCents: publisher_user.pendingCommissionCents.to_i + commission,
                totalCommissionCents: publisher_user.totalCommissionCents.to_i + commission
              )
              publishers << Publisher.new(user: publisher_user, order_items: items, commission: commission)
            end
          end

          CheckoutJob.perform_async(order.id, user)
          OrderMailer.delay.received(order.id)

          publishers.each do |publisher|
            OrderMailer.delay.placed(
              order.id,
              publisher.user.id,
              publisher.order_items.map(&:id),
              publisher.commission
            )
          end

          status :accepted
          present order, with: API::V2::Entities::Order, publishers: publishers
        end
      end
    end
  end
end
