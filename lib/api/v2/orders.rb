module API
  module V2
    class Orders < Grape::API
      include Validations
      desc 'post order to process'
      params do
        requires :payment,                type: Hash
        requires :user,                   type: Hash
        requires :shippingAddress,        type: Hash
        requires :items,                  type: Array
        group    :items,                  type: Array, validate_prices: true do
          requires :listPriceCents,       type: Integer
          requires :salePriceCents,       type: Integer
          requires :variantId,            type: Integer
          requires :quantity,             type: Integer
          requires :sourceUrl,            type: String
          requires :apiKey,               type: String
          requires :widgetUuid,           type: String
        end
        requires :shippingCents,          type: Integer
        requires :taxCents,               type: Integer
        requires :notes,                  type: String
        requires :shareWithPublisher,     type: Boolean
        requires :apiKey,                 type: String
        requires :sourceUrl,              type: String
        optional :theme,                  type: String
      end

      resources :orders do
        post '/' do
          Rails.logger.info params.to_hash.inspect
          ActiveRecord::Base.transaction do
            payment = declared_params[:payment]
            payment_record = Payment.create!(name: payment[:name], number: payment[:number], cvv: payment[:cvv],
                            expirationYear: payment[:expirationYear], expirationMonth: payment[:expirationMonth],
                            type: payment[:type], createdAt: Time.now, updatedAt: Time.now, status: 1)

            user = declared_params[:user]
            user_record = User.create_with( first_name: user[:firstName], last_name: user[:lastName],
                                            api_key: uid("#{user[:email]}-#{Time.now.to_i}"), status: 1, createdAt: Time.now,
                                            updatedAt: Time.now, password: user[:password])
                              .find_or_create_by!( email: user[:email])

            shipping = declared_params[:shippingAddress]
            shipping_addr = Address.create!(address1: shipping[:address1], address2: shipping[:address2],
                            city: shipping[:city], state: shipping[:state], zip: shipping[:zip],
                            phone_number: shipping[:phoneNumber], status: 1, address_type: 1, user_id: user_record.id,
                            createdAt: Time.now, updatedAt: Time.now)

            billing = payment[:billingAddress]
            billing_addr = Address.create!(address1: billing[:address1], address2: billing[:address2],
                            city: billing[:city], state: billing[:state], zip: billing[:zip],
                            phone_number: billing[:phoneNumber], status: 1, address_type: 2, user_id: user_record.id,
                            createdAt: Time.now, updatedAt: Time.now)

            order = Order.create!(shippingCents: declared_params[:shippingCents] || 0, taxCents: declared_params[:taxCents],
                                  orderTotalCents: 0, notes: declared_params[:notes], appliedCommissionCents: 0,
                                  ShippingAddressId: shipping_addr.id, BillingAddressId: billing_addr.id,
                                  UserId: user_record.id, PaymentId: payment_record.id, shareWithPublisher: declared_params[:shareWithPublisher],
                                  apiKey: declared_params[:apiKey], sourceUrl: declared_params[:sourceUrl], theme: declared_params[:theme],
                                  createdAt: Time.now, updatedAt: Time.now)
            partners = []
            item_records = []
            handle_param(:items) do |items|
              items.each do |item|
                record = OrderItem.create!(OrderId: order.id, VariantId: item[:variantId], quantity: item[:quantity], listPriceCents: item[:listPriceCents],
                                  salePriceCents: item[:salePriceCents], sourceUrl: item[:sourceUrl], apiKey: item[:apiKey],
                                  widgetUuid: item[:widgetUuid], createdAt: Time.now, updatedAt: Time.now, commissionCents: 0)
                partners << record.product.partner.first.name
                item_records << record
              end
            end
            CheckoutJob.perform_async(order.id)
            OrderMailer.received(order: order, user: user_record, partners: partners.uniq.join(", "), source_url: declared_params[:sourceUrl],
                                 items: item_records, shipping_address: shipping_addr, billing_address: billing_addr).deliver_now
          end
        end
      end

      helpers do
        def uid(data)
          digest = Digest::MD5.hexdigest(data)
          "#{digest[0...8]}-#{digest[8...12]}-4#{digest[13...16]}-#{digest[16...20]}-#{digest[20...32]}"
        end
      end
    end
  end
end
