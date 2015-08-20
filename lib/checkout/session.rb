module Checkout
  class Session
    attr_reader :user

    def initialize(order)
      @order = order
      @user = order.user
    end

    def commit(item)
      @item = item
      @item.process!
      partner.purchase
    rescue ProductOutOfStock
      item.mark_as_out_of_stock! && raise
    rescue ProductUnprocessed
      item.mark_as_unprocessed! && raise
    rescue StandardError
      item.abort! && raise
    else
      item.mark_as_processed!
    end

    def product_url
      item.variant_source_url
    end

    def product_quantity
      item.quantity
    end

    def product_price
      item.sale_price_cents
    end

    def shipping_address
      {
        gender: 'm',
        first_name: user.first_name,
        last_name: user.last_name,
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
        first_name: user.first_name,
        last_name: user.last_name,
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

    attr_reader :order, :item

    def partner
      Partners.lookup(product_url).new(self)
    end
  end
end
