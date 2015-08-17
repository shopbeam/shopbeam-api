module Checkout
  class Shopper
    include Wisper::Publisher

    def self.call(*args)
      new(*args).call
    end

    def initialize(order, listener)
      @order = order

      subscribe(listener)
    end

    def call
      session = Session.new(order)

      order.order_items.each do |item|
        session.commit(item)
      end

      broadcast(:checkout_successful, order)
    rescue
      broadcast(:checkout_failed, order)
    end

    private

    attr_reader :order
  end
end
