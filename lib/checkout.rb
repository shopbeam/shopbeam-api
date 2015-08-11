module Checkout
  class PartnerNotSupported < StandardError
    def initialize(url)
      super("Checkout partner not supported for '#{url}'")
    end
  end
end
