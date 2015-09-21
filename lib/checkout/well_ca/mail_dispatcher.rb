module Checkout
  module WellCa
    class MailDispatcher < MailDispatcherBase
      private

      def validator
        @validator ||= begin
          case mail
          when Validators::OrderReceived   then Validators::OrderReceived
          when Validators::OrderProcessing then Validators::OrderProcessing
          when Validators::OrderShipped    then Validators::OrderShipped
          end
        end
      end
    end
  end
end
