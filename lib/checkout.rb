module Checkout
  class OrderError < StandardError; end

  class PartnerNotSupportedError < OrderError
    def initialize(url)
      super "Checkout partner not supported for '#{url}'"
    end
  end

  class InvalidAccountError < OrderError; end
  class ItemOutOfStockError < OrderError; end
  class ItemPriceMismatchError < OrderError; end
  class InvalidAddressError < OrderError; end
  class InvalidShippingInfoError < OrderError; end
  class InvalidBillingInfoError < OrderError; end
  class ConfirmationError < OrderError; end
end
