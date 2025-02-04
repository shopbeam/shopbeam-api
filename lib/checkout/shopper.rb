module Checkout
  class Shopper
    include Wisper::Publisher

    def call(order_id, customer)
      order = Order.uncompleted.find(order_id)
      session = Session.new(order)

      order.customer = customer
      session.customer_password = customer.try(:[], 'password')

      order.process!

      order.order_items.group_by(&:bot).each do |bot, items|
        bot.new(session).purchase!(items)
      end
    rescue ActiveRecord::RecordNotFound
      broadcast :order_not_found, order_id
    rescue InvalidOrderNumberError => exception
      order.complete!
      broadcast :order_completed_with_error, order, exception
    rescue CheckoutError => exception
      order.terminate!
      broadcast :order_terminated, order, exception
      raise
    rescue StandardError => exception
      order.abort!
      broadcast :order_aborted, order, exception
      raise
    else
      order.complete!
      broadcast :order_completed, order
    end
  end
end
