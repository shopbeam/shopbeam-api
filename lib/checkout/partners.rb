module Checkout
  module Partners
    def self.lookup(url)
      case url
      when /https:\/\/well.ca/
        WellCa
      else
        raise PartnerNotSupportedError.new(url, 'Checkout partner not supported.')
      end
    end
  end
end
