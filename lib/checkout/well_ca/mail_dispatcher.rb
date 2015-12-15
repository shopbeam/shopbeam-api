module Checkout
  module WellCa
    class MailDispatcher < MailDispatcherBase
      private

      def validator
        super do
          case mail
          when Validators::OrderReceived   then Validators::OrderReceived
          when Validators::OrderProcessing then Validators::OrderProcessing
          when Validators::OrderShipped    then Validators::OrderShipped
          when Validators::OrderCanceled   then Validators::OrderCanceled
          end
        end
      end
    end
  end
end
