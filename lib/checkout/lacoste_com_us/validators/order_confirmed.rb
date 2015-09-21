module Checkout
  module LacosteComUs
    module Validators
      module OrderConfirmed
        extend ProxyMailValidator

        def self.===(mail)
          mail.from =~ %r(noreply-staging@lacoste.com) &&
          mail.subject =~ /\AConfirmation of your Order \d+\z/
        end
      end
    end
  end
end
