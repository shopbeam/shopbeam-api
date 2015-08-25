module Checkout
  class Session
    delegate :user, to: :order

    def initialize(order)
      @order = order
    end

    def shipping_address
      {
        gender: 'm',
        first_name: order.shipping_first_name,
        last_name: order.shipping_last_name,
        address1: order.shipping_address1,
        address2: order.shipping_address2,
        city: order.shipping_city,
        state: order.shipping_state,
        zip: order.shipping_zip
      }
    end

    def billing_address
      {
        gender: 'm',
        first_name: order.billing_first_name,
        last_name: order.billing_last_name,
        address1: order.billing_address1,
        address2: order.billing_address2,
        city: order.billing_city,
        state: order.billing_state,
        zip: order.billing_zip
      }
    end

    def cc
      {
        name: order.cc_name,
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
