module Checkout
  module Registrators
    def self.lookup!(partner_type)
      "Checkout::#{partner_type}::Registrator".constantize
    rescue NameError
      raise PartnerNotSupportedError.new(partner_type, 'Account registrator not supported.')
    end
  end
end
