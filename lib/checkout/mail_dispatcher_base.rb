module Checkout
  class MailDispatcherBase
    def initialize(params)
      @params = params
      @mail = ProxyMail.new(mail_params)
    end

    def call
      proxy_user = ProxyUser.find_by!(email: mail.recipient)
      options = validator.parse!(mail.body)

      ProxyMailer.forward(
        to: proxy_user.user_email,
        proxy_mail: mail,
        body: Checkout::MailTemplate.new(proxy_user, validator, options).render
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
    rescue MailThemeNotFoundError => exception
      ProxyMailer.theme_not_found(
        proxy_mail: mail,
        dispatcher: self.class,
        number: exception.number
      ).deliver_now
      raise
    rescue MailTemplateNotFoundError => exception
      ProxyMailer.template_not_found(
        proxy_mail: mail,
        dispatcher: self.class,
        filename: exception.filename
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
        body: params[:'body-html']
      }
    end

    def validator
      @validator ||= yield || (raise UnknownMailError)
    end
  end
end
