module Checkout
  class Notifier
    # TODO: pass order.id to mailers here and below
    def order_completed(order)
      CheckoutMailer.completed(order).deliver_now
    end

    def order_completed_with_error(order, exception)
      CheckoutMailer.completed_with_error(order, exception).deliver_now
    end

    def order_not_found(order_id)
      CheckoutMailer.not_found(order_id).deliver_now
    end

    def order_terminated(order, exception)
      CheckoutMailer.delay.terminated(order, exception)
      UserMailer.delay.order_error(order, exception)
    end

    def order_aborted(order, exception)
      CheckoutMailer.aborted(order, exception).deliver_now
    end

    def account_activated(account)
      AccountMailer.activated(account).deliver_now
    end

    def account_not_found(account_id)
      AccountMailer.not_found(account_id).deliver_now
    end

    def account_aborted(account, exception)
      AccountMailer.aborted(account, exception).deliver_now
    end
  end
end
