module Checkout
  module Bots
    def self.lookup!(url)
      case url
      # TODO: Extract URL patterns into constants
      when %r(https?://advertisingweek.eu)
        AdvertisingweekEu::Bot
      when %r((https?://www.lacoste.com/us)|(http://click.linksynergy.com(.*?)www.lacoste.com))
        LacosteComUs::Bot
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
