class CheckoutJob
  include Sidekiq::Worker
  sidekiq_options retry: 0, backtrace: 5

  def perform(order_id, customer)
    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order_id, customer)
  end
end
