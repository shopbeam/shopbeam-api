class CheckoutJob < ActiveJob::Base
  queue_as :default

  def perform(order_id)
    order = Order.uncompleted.find(order_id)

    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order)
  end
end
