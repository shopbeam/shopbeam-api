module Checkout
  module Partners
    def self.lookup(url)
      case url
      when %r(https?://well.ca)
        WellCa
      when %r(https?://www.lacoste.com/us)
        LacosteComUs
      else
        raise PartnerNotSupportedError.new(url, 'Checkout partner not supported.')
      end
    end
  end
end
