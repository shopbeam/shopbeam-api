module Checkout
  class PartnerNotSupported < StandardError
    def initialize(url)
      super "Checkout partner not supported for '#{url}'"
    end
  end

  class InvalidAddress < StandardError
    def initialize(address, partner)
      super "Invalid address for '#{partner}': #{address}"
    end
  end

  class InvalidShippingInfo < StandardError; end

  class InvalidBillingInfo < StandardError
    def initialize(message, partner)
      super "Invalid billing information for '#{partner}': #{message}"
    end
  end

  class UnknownError < StandardError
    def initialize(message, partner)
      super "Unknown error for '#{partner}': #{message}"
    end
  end
end
