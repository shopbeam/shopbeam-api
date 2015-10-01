module Checkout
  module WellCa
    module Validators
      module OrderShipped
        extend MailValidator

        def self.===(mail)
          mail.from =~ %r(orders@well.ca) &&
          mail.subject =~ /\AOrder Update \w+\z/ &&
          mail.body_html =~ /Your order has been picked, packed and shipped for delivery and should arrive shortly/ &&
          mail.body_plain =~ /Your order has been picked, packed and shipped for delivery/
        end
      end
    end
  end
end
