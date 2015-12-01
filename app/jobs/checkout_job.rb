class CheckoutJob
  include Sidekiq::Worker
  sidekiq_options retry: 2, backtrace: 5

  sidekiq_retries_exhausted do |msg|
    order = Order.find(msg['args'].first)

    error_code =
      case msg['error_class']
      when 'Checkout::VariantNotAvailableError',
           'Checkout::ItemOutOfStockError',
           'Checkout::ItemPriceMismatchError'
        :item_out_of_stock
      when 'Checkout::InvalidAddressError',
           'Checkout::InvalidShippingInfoError',
           'Checkout::InvalidBillingInfoError'
        :invalid_address
      when 'Checkout::ConfirmationError'
        :invalid_cc
      end

    UserMailer.order_error(order, error_code, msg['error_message']).deliver_now if error_code
  end

  def perform(order_id)
    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order_id)
  end
end
