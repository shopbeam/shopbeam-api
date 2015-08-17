module Checkout
  class Session
    attr_reader :order, :user, :item

    def initialize(order)
      @order = order
      @user = order.user
    end

    def commit(item)
      @item = item
      partner.purchase
    end

    def product_url
      item.variant_source_url
    end

    def product_quantity
      item.quantity
    end

    private

    def partner
      Partners.lookup(product_url).new(self)
    end
  end
end
