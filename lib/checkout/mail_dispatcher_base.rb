module Checkout
  class MailDispatcherBase
    def initialize(params)
      @params = params
      @mail = ProxyMail.new(mail_params)
    end

    def call
      unless proxy_user
        return ProxyMailer.recipient_not_found(mail.recipient).deliver_now
      end

      unless validator
        return ProxyMailer.unknown_mail(mail, self.class).deliver_now
      end

      unless validator.validate_and_sanitize!(mail.body_html, :html) &&
             validator.validate_and_sanitize!(mail.body_plain, :text)
        return ProxyMailer.invalid_mail(mail, self.class, validator).deliver_now
      end

      ProxyMailer.forward(proxy_user.user_email, mail).deliver_now
    end

    protected

    attr_reader :params, :mail

    def mail_params
      {
        from: params[:from],
        recipient: params[:recipient],
        subject: params[:subject],
        body_html: params[:'body-html'],
        body_plain: params[:'body-plain']
      }
    end

    def proxy_user
      @proxy_user ||= ProxyUser.find_by_email(mail.recipient)
    end

    def validator
      raise NotImplementedError, 'Subclasses must implement a validator method.'
    end
  end
end
