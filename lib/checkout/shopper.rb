module Checkout
  class Shopper
    include Wisper::Publisher

    def call(order)
      session = Session.new(order)

      order.process!

      order.order_items.group_by(&:partner).each do |partner, items|
        partner.new(session).purchase(items)
      end
    rescue OrderError
      order.terminate!
      broadcast :order_terminated, order
      raise
    rescue StandardError
      order.abort!
      broadcast :order_aborted, order
      raise
    else
      order.complete!
      broadcast :order_completed, order
    end
  end
end
