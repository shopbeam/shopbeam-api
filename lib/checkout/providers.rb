module Checkout
  module Providers
    def self.lookup(url)
      case url
      when /https:\/\/well.ca/
        WellCa
      else
        raise ProviderNotSupported.new(url)
      end
    end
  end
end
