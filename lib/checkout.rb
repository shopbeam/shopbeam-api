module Checkout
  class ProviderNotSupported < StandardError
    def initialize(url)
      super("Checkout provider not supported for '#{url}'")
    end
  end
end
