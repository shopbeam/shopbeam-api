class CheckoutJob < ActiveJob::Base
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

    Checkout::Submitter.new(order).tap do |s|
      s.subscribe(Checkout::Notifier.new)
      s.call
    end
  end
end
