module Checkout
  class Session
    delegate :id, :user, :save_reference!, to: :order

    def initialize(order)
      @order = order
    end

    def shipping_address
      {
        first_name: order.user_first_name,
        last_name: order.user_last_name,
        address1: order.shipping_address1,
        address2: order.shipping_address2,
        city: order.shipping_city,
        state: order.shipping_state,
        zip: order.shipping_zip,
        phone: order.shipping_phone_number
      }
    end

    def billing_address
      {
        first_name: order.user_first_name,
        last_name: order.user_last_name,
        address1: order.billing_address1,
        address2: order.billing_address2,
        city: order.billing_city,
        state: order.billing_state,
        zip: order.billing_zip,
        phone: order.billing_phone_number
      }
    end

    def cc
      {
        name: order.cc_name,
        brand: order.cc_brand,
        number: order.cc_number,
        cvv: order.cc_cvv,
        expiration_month: order.cc_expiration_month,
        expiration_year: order.cc_expiration_year
      }
    end

    private

    attr_reader :order
  end
end
