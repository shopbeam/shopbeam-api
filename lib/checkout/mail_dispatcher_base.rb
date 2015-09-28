module Checkout
  class MailDispatcherBase
    def initialize(params)
      @params = params
      @mail = ProxyMail.new(mail_params)
    end

    def call
      proxy_user = ProxyUser.find_by!(email: mail.recipient)
      html_options = validator.parse!(mail.body_html, :html)
      text_options = validator.parse!(mail.body_plain, :text)

      ProxyMailer.forward(
        to: proxy_user.user_email,
        proxy_mail: mail,
        html: Checkout::MailTemplate.new(proxy_user, validator, html_options).html,
        text: Checkout::MailTemplate.new(proxy_user, validator, text_options).text
      ).deliver_now
    rescue ActiveRecord::RecordNotFound
      ProxyMailer.recipient_not_found(mail.recipient).deliver_now
      raise
    rescue UnknownMailError
      ProxyMailer.unknown_mail(
        proxy_mail: mail,
        dispatcher: self.class
      ).deliver_now
      raise
    rescue InvalidMailError => exception
      ProxyMailer.invalid_mail(
        proxy_mail: mail,
        dispatcher: self.class,
        validator: validator.to_s.demodulize.titleize,
        diff: exception.diff
      ).deliver_now
      raise
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

    def validator
      @validator ||= yield || (raise UnknownMailError)
    end
  end
end
