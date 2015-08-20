module Checkout
  class Shopper
    include Wisper::Publisher

    def self.call(*args)
      new(*args).call
    end

    def initialize(order, listener)
      @order = order

      subscribe listener
    end

    def call
      session = Session.new(order)

      order.process!

      order.order_items.each do |item|
        session.commit(item)
      end
    rescue StandardError => exception
      broadcast :checkout_failed, order
      raise
    else
      broadcast :checkout_successful, order
    ensure
      order.finish!
    end

    private

    attr_reader :order
  end
end
