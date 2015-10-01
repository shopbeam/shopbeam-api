module Checkout
  module LacosteComUs
    class MailDispatcher < MailDispatcherBase
      private

      def validator
        super do
          case mail
          when Validators::OrderConfirmed then Validators::OrderConfirmed
          when Validators::OrderShipped   then Validators::OrderShipped
          end
        end
      end
    end
  end
end
