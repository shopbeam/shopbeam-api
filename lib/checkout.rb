module Checkout
  class CheckoutError < StandardError; end

  class PartnerNotSupported < CheckoutError
    def initialize(url)
      super "Checkout partner not supported for '#{url}'"
    end
  end

  class ProductOutOfStock < CheckoutError; end
  class ProductPriceMismatch < CheckoutError; end
  class ProductUnprocessed < CheckoutError; end
  class InvalidAddress < CheckoutError; end
  class InvalidShippingInfo < CheckoutError; end
  class InvalidBillingInfo < CheckoutError; end
  class UnknownError < CheckoutError; end
end
