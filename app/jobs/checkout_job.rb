class CheckoutJob
  include Sidekiq::Worker
  sidekiq_options retry: 0, backtrace: 5

  # TODO: no longer need to use exhausted block with retry 0
  sidekiq_retries_exhausted do |msg|
    order = Order.find(msg['args'].first)

    error_code =
      case msg['error_class']
      when 'Checkout::InvalidCredentialsError'
        :invalid_credentials
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

    OrderMailer.terminated_with_error(order, error_code, msg['error_message']).deliver_now if error_code
  end

  def perform(order_id, customer)
    Checkout::Shopper.new
      .subscribe(Checkout::Notifier.new)
      .call(order_id, customer)
  end
end
