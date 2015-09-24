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

      html_options = validator.parse(mail.body_html, :html)
      text_options = validator.parse(mail.body_plain, :text)

      unless html_options && text_options
        return ProxyMailer.invalid_mail(mail, self.class, validator).deliver_now
      end

      ProxyMailer.forward(
        to: proxy_user.user_email,
        proxy_mail: mail,
        html: Checkout::ProxyMailTemplate.new(proxy_user, validator, html_options).html,
        text: Checkout::ProxyMailTemplate.new(proxy_user, validator, text_options).text
      ).deliver_now
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
