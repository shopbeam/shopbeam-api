class CheckoutJob < ActiveJob::Base
  queue_as :default

  def perform(order_id)
    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order_id)
  end
end
