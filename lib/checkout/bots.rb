module Checkout
  module Bots
    def self.lookup!(url)
      case url
      when %r(https?://well.ca)
        WellCa::Bot
      when %r(https?://www.lacoste.com/us)
        LacosteComUs::Bot
      else
        raise PartnerNotSupportedError.new(url, 'Checkout partner not supported.')
      end
    end
  end
end
