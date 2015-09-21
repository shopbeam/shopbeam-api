module Checkout
  module WellCa
    module Validators
      module OrderProcessing
        extend ProxyMailValidator

        def self.===(mail)
          mail.from =~ %r(orders@well.ca) &&
          mail.subject =~ /\AOrder Update \w+\z/ &&
          mail.body_html =~ /Your order is now being processed/ &&
          mail.body_plain =~ /Your order is now processing/
        end
      end
    end
  end
end
