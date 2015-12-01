module Checkout
  module WellCa
    module Validators
      module OrderShipped
        extend MailValidator

        def self.===(mail)
          mail.from =~ %r(orders@well.ca) &&
          mail.subject =~ /\AOrder Update \w+\z/ &&
          mail.body =~ /Your order has been picked, packed and shipped for delivery and should arrive shortly/
        end
      end
    end
  end
end
