module Checkout
  class Shopper
    include Wisper::Publisher

    def self.call(*args)
      new(*args).call
    end

    def initialize(order, listener)
      @order = order
      @session = Session.new(order.user)

      subscribe(listener)
    end

    def call
      order.order_items.each do |item|
        session.commit(item)
      end

      broadcast(:checkout_successful, order)
    rescue
      broadcast(:checkout_failed, order)
    end

    private

    attr_reader :order, :session
  end
end
