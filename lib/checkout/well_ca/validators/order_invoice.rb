module Checkout
  module WellCa
    module Validators
      module OrderInvoice
        extend MailValidator

        def self.===(mail)
          mail.from == 'orders@well.ca' &&
          mail.subject =~ /\AOrder Invoice: \w+\z/
        end
      end
    end
  end
end
