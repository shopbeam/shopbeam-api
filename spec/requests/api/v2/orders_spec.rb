# TODO: generate apiKey in factories implicitly with Faker or SecureRandom.uuid
# TODO: add publishers node in the response
# TODO: test transaction
# TODO: test price validation

require 'rails_helper'

describe API::V2::Orders, api: :true do
  describe 'POST /' do
    describe 'params validation' do
      # TODO
    end

    context 'when params are valid' do
      describe 'user' do
        context 'when user exists' do
          it 'does not create user record' do
            user = create(:user)
            order_params = build(:order_params)
            order_params[:user][:email] = user.email

            expect {
              post v2_orders_path, **order_params
            }.not_to change(User, :count)
          end
        end

        context 'when user does not exist' do
          it 'creates user record' do
            expect {
              post v2_orders_path, **build(:order_params)
            }.to change(User, :count).by(1)
          end

          it 'saves user details' do
            order_params = build(:order_params)
            order_params[:user][:firstName] = 'John'

            post v2_orders_path, **order_params

            expect(User.last.first_name).to eq('John')
          end
        end
      end

      describe 'payment' do
        it 'creates payment record' do
          expect {
            post v2_orders_path, **build(:order_params)
          }.to change(Payment, :count).by(1)
        end

        it 'saves payment details' do
          order_params = build(:order_params)
          order_params[:payment][:name] = 'John Smith'

          post v2_orders_path, **order_params

          payment = Payment.last

          expect(payment.name).to eq('John Smith')
          expect(payment.UserId).to eq(User.last.id)
        end
      end

      describe 'shipping address' do
        it 'creates address record' do
          expect {
            post v2_orders_path, **build(:order_params)
          }.to change(ShippingAddress, :count).by(1)
        end

        it 'saves address details' do
          order_params = build(:order_params)
          order_params[:shippingAddress][:city] = 'New York'

          post v2_orders_path, **order_params

          shipping_address = ShippingAddress.last

          expect(shipping_address.city).to eq('New York')
          expect(shipping_address.UserId).to eq(User.last.id)
        end
      end

      describe 'billing address' do
        it 'creates address record' do
          expect {
            post v2_orders_path, **build(:order_params)
          }.to change(BillingAddress, :count).by(1)
        end

        it 'saves address details' do
          order_params = build(:order_params)
          order_params[:payment][:billingAddress][:city] = 'New York'

          post v2_orders_path, **order_params

          billing_address = BillingAddress.last

          expect(billing_address.city).to eq('New York')
          expect(billing_address.UserId).to eq(User.last.id)
        end
      end

      describe 'order' do
        it 'creates order record' do
          expect {
            post v2_orders_path, **build(:order_params)
          }.to change(Order, :count).by(1)
        end

        context 'when billing zip is 00000' do
          it 'creates test order' do
            order_params = build(:order_params)
            order_params[:payment][:billingAddress][:zip] = '00000'

            post v2_orders_path, **order_params

            expect(Order.last).to be_test
          end
        end

        context 'when billing zip is not 00000' do
          it 'creates pending order' do
            order_params = build(:order_params)
            order_params[:payment][:billingAddress][:zip] = '11111'

            post v2_orders_path, **order_params

            expect(Order.last).to be_pending
          end
        end

        it 'saves order details' do
          order_params = build(:order_params)
          order_params[:notes] = 'Test Order'

          post v2_orders_path, **order_params

          order = Order.last

          expect(order.notes).to eq('Test Order')
          expect(order.UserId).to eq(User.last.id)
          expect(order.PaymentId).to eq(Payment.last.id)
          expect(order.ShippingAddressId).to eq(ShippingAddress.last.id)
          expect(order.BillingAddressId).to eq(BillingAddress.last.id)
        end

        it 'calculates order total' do
          variants = [
            create(:variant, salePriceCents: nil, listPriceCents: 100),
            create(:variant, salePriceCents: 150, listPriceCents: 200),
            create(:variant, salePriceCents: 300, listPriceCents: 300)
          ]

          order_params = build(:order_params, variants: variants)
          order_params[:items][0][:quantity] = 2
          order_params[:items][1][:quantity] = 3
          order_params[:items][2][:quantity] = 4

          post v2_orders_path, **order_params

          expect(Order.last.orderTotalCents).to eq(2*100 + 3*150 + 4*300)
        end

        # it 'calculates order applied commission' # TODO
      end

      describe 'order items' do
        it 'creates order item records' do
          expect {
            variants = create_list(:variant, 2)
            order_params = build(:order_params, variants: variants)

            post v2_orders_path, **order_params
          }.to change(OrderItem, :count).by(2)
        end

        context 'when billing zip is 00000' do
          it 'creates test order item' do
            variants = [create(:variant)]
            order_params = build(:order_params, variants: variants)
            order_params[:payment][:billingAddress][:zip] = '00000'

            post v2_orders_path, **order_params

            expect(OrderItem.last).to be_test
          end
        end

        context 'when billing zip is not 00000' do
          it 'creates pending order item' do
            variants = [create(:variant)]
            order_params = build(:order_params, variants: variants)
            order_params[:payment][:billingAddress][:zip] = '11111'

            post v2_orders_path, **order_params

            expect(OrderItem.last).to be_pending
          end
        end

        it 'saves order item details' do
          variants = [create(:variant)]
          order_params = build(:order_params, variants: variants)
          order_params[:items][0][:sourceUrl] = 'http://foo.com/'

          post v2_orders_path, **order_params

          expect(OrderItem.last.sourceUrl).to eq('http://foo.com/')
        end

        # it 'calculates order item commission' # TODO
      end

      describe 'response' do
        it 'matches response schema' do
          post v2_orders_path, **build(:order_params)

          expect(response).to have_http_status(202)
          expect(json_response).not_to be_empty
          expect(response).to match_response_schema('order')
        end

        # it 'contains publishers' # TODO
      end
    end

    context 'when params are invalid' do
      it 'responds with error' do
        post v2_orders_path, **build(:invalid_order_params)

        expect(response).to have_http_status(400)
        expect(json_response['error']).not_to be_empty
      end
    end
  end
end
