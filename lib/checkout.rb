module Checkout
  class PartnerNotSupported < StandardError
    def initialize(url)
      super("Checkout partner not supported for '#{url}'")
    end
  end

  class InvalidAddress < StandardError
    def initialize(address, partner)
      super("Invalid address for '#{partner}': #{address}")
    end
  end
end
