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
        requires :notes,              type: String
        requires :shareWithPublisher, type: Boolean
        requires :apiKey,             type: String
        requires :sourceUrl,          type: String
        optional :theme,              type: String
      end
      resource :orders do
        post do
          # TODO: below looks REALLY messy, extract into service object
          ActiveRecord::Base.transaction do
            user = declared_params[:user]
            user_record = User.create_with( first_name: user[:firstName], last_name: user[:lastName],
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
            partners = []
            item_records = []
            order_total = 0
            order_applied_commission = 0
            publisher_commissions = Hash.new(0)
            with_param(:items) do |items|
              items.each do |item|
                variant = Variant.find(item[:variantId])
                record = OrderItem.create!(OrderId: order.id, VariantId: item[:variantId], quantity: item[:quantity], listPriceCents: variant.list_price_cents,
                                  status: order_status, salePriceCents: variant.sale_price_cents, sourceUrl: item[:sourceUrl], apiKey: item[:apiKey],
                                  widgetUuid: item[:widgetUuid], createdAt: Time.now, updatedAt: Time.now, commissionCents: variant.commission_cents(item[:quantity]))
                partners << record.product.partner.name
                item_records << record
                order_total += record.total_price_cents
                order_applied_commission += record.commission_cents
                publisher_commissions[record.api_key] += record.commission_cents
              end
            end
            order.update!(orderTotalCents: order_total, appliedCommissionCents: order_applied_commission)
            publishers = []
            publisher_commissions.each do |api_key, commission|
              publisher = User.find_by!(api_key: api_key)
              publisher.update_attributes!(
                pendingCommissionCents: publisher.pendingCommissionCents.to_i + commission,
                totalCommissionCents: publisher.totalCommissionCents.to_i + commission
              )
              publishers << publisher.slice(:apiKey, :email, :firstName, :lastName).merge(commission: commission)
            end
            CheckoutJob.perform_async(order.id, user)
            OrderMailer.received(order: order, user: user_record, partners: partners.uniq.join(", "), source_url: declared_params[:sourceUrl],
                                 items: item_records, shipping_address: shipping_addr, billing_address: billing_addr).deliver_now
            partner_user = User.find_by(apiKey: item_records.first.apiKey, status: 1)
            OrderMailer.publisher(order: order, user: user_record, partners: partners.uniq.join(", "), source_url: declared_params[:sourceUrl],
                                 items: item_records, shipping_address: shipping_addr, billing_address: billing_addr,
                                 partner: partner_user).deliver_now

            status :accepted
            present order, with: API::V2::Entities::Order, publishers: publishers
          end
        end
      end
    end
  end
end
