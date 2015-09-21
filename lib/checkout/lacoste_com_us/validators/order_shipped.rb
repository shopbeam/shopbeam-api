module Checkout
  module LacosteComUs
    module Validators
      module OrderShipped
        extend ProxyMailValidator

        def self.===(mail)
          mail.from =~ %r(no-reply@lacoste.us) &&
          mail.subject =~ /\AShipment confirmation of your Lacoste order nº\w+\z/
        end
      end
    end
  end
end
