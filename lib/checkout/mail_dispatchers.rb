module Checkout
  module MailDispatchers
    def self.lookup(from)
      case from
      when %r(.*@well.ca)
        WellCa::MailDispatcher
      when %r(.*@lacoste.(com|us))
        LacosteComUs::MailDispatcher
      end
    end
  end
end
