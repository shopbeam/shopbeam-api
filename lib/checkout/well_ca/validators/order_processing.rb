module Checkout
  module WellCa
    module Validators
      module OrderProcessing
        extend MailValidator

        def self.===(mail)
          mail.from =~ %r(orders@well.ca) &&
          mail.subject =~ /\AOrder Update \w+\z/ &&
          mail.body =~ /Your order is now being processed/
        end
      end
    end
  end
end
