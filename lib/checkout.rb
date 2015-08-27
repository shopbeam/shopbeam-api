module Checkout
  class OrderError < StandardError
    def initialize(url, message)
      @url = url
      @message = message
    end

    def to_s
      "#{self.class.name.demodulize}: The following error(s) occurred on #{@url}: #{@message}"
    end
  end

  class ItemOutOfStockError < OrderError
    def initialize(url:, requested_qty:, actual_qty:)
      super url, "#{requested_qty} requested but #{actual_qty} available."
    end
  end

  class ItemPriceMismatchError < OrderError
    include ActionView::Helpers::NumberHelper

    def initialize(url:, requested_price_cents:, actual_price_cents:)
      super url, "#{number_to_currency(requested_price_cents / 100.0)} expected but #{number_to_currency(actual_price_cents / 100.0)} got."
    end
  end

  class InvalidStateError < OrderError
    def initialize(url, code)
      super url, "State with code '#{code}' not supported."
    end
  end

  class PartnerNotSupportedError < OrderError; end
  class InvalidAccountError < OrderError; end
  class InvalidAddressError < OrderError; end
  class InvalidShippingInfoError < OrderError; end
  class InvalidBillingInfoError < OrderError; end
  class ConfirmationError < OrderError; end
end
