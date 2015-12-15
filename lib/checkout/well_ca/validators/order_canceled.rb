module Checkout
  module WellCa
    module Validators
      module OrderCanceled
        extend MailValidator

        def self.===(mail)
          mail.from == 'orders@well.ca' &&
          mail.subject =~ /\AOrder Update \w+\z/ &&
          mail.body =~ /We have cancelled your order/
        end
      end
    end
  end
end
