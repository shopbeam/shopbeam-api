module Checkout
  module MailDispatchers
    def self.lookup(sender)
      # TODO: temporary forward all emails with proxy dispatcher
      ProxyMailDispatcher
    end
  end
end
