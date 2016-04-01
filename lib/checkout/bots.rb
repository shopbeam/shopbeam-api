module Checkout
  module Bots
    def self.lookup!(url)
      case url
      when %r(https?://advertisingweek.eu)
        AdvertisingweekEu::Bot
      # TODO: Temporarily disable Lacoste partner
      # when %r(https?://www.lacoste.com/us)
      #   LacosteComUs::Bot
      when %r(http://www.target.com)
        TargetCom::Bot
      when %r(https?://well.ca)
        WellCa::Bot
      else
        raise PartnerNotSupportedError.new(url, 'Checkout partner not supported.')
      end
    end
  end
end
