module Checkout
  class Notifier
    def order_completed(order)
      OrderMailer.completed(order).deliver_now
    end

    def order_terminated(order)
      OrderMailer.terminated(order, $!).deliver_now
    end

    def order_aborted(order)
      OrderMailer.aborted(order, $!).deliver_now
    end
  end
end
