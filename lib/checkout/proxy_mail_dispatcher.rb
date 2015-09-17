module Checkout
  class ProxyMailDispatcher < MailDispatcherBase
    def call
      if proxy_user
        ProxyMailer.forward(delivery_options).deliver_now
      else
        ProxyMailer.recipient_not_found(params[:recipient]).deliver_now
      end
    end
  end
end
