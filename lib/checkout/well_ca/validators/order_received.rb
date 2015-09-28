module Checkout
  module WellCa
    module Validators
      module OrderReceived
        extend MailValidator

        def self.===(mail)
          mail.from =~ %r(info@well.ca) &&
          mail.subject =~ /\AOrder Confirmation No: \w+\z/
        end
      end
    end
  end
end
