module Checkout
  class Notifier
    def order_completed(order)
      OrderMailer.completed(order).deliver_now
    end

    def order_completed_with_error(order, exception)
      OrderMailer.completed_with_error(order, exception).deliver_now
    end

    def order_not_found(order_id)
      OrderMailer.not_found(order_id).deliver_now
    end

    def order_terminated(order, exception)
      OrderMailer.terminated(order, exception).deliver_now
    end

    def order_aborted(order, exception)
      OrderMailer.aborted(order, exception).deliver_now
    end
  end
end
