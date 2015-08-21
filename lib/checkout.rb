module Checkout
  class CheckoutError < StandardError; end

  class PartnerNotSupportedError < CheckoutError
    def initialize(url)
      super "Checkout partner not supported for '#{url}'"
    end
  end

  class InvalidAccountError < CheckoutError; end
  class ItemOutOfStockError < CheckoutError; end
  class ItemPriceMismatchError < CheckoutError; end
  class ItemUnprocessedError < CheckoutError; end
  class InvalidAddressError < CheckoutError; end
  class InvalidShippingInfoError < CheckoutError; end
  class InvalidBillingInfoError < CheckoutError; end
  class UnknownError < CheckoutError; end
end
