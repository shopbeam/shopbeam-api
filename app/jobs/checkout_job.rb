class CheckoutJob
  include Sidekiq::Worker
  sidekiq_options retry: 2, backtrace: 5

  def perform(order_id)
    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order_id)
  end
end
