class CheckoutJob < ActiveJob::Base
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

    Checkout::Shopper.call(order, Checkout::Notifier.new)
  end
end
