class ProxyMailer < ApplicationMailer
  # only/except options do not work in ActionMailer properly, use method instead
  layout :proxy_mailer_layout

  def forward(user_email, proxy_mail)
    mail to: user_email,
         bcc: 'support@shopbeam.com',
         subject: proxy_mail.subject do |format|
      format.html { render html: proxy_mail.body_html.html_safe }
      format.text { render plain: proxy_mail.body_plain }
    end
  end

  def recipient_not_found(recipient)
    @recipient = recipient

    mail to: 'tech@shopbeam.com',
         cc: 'support@shopbeam.com',
         subject: "[order-manager:proxy-mailer] Recipient not found"
  end

  def unknown_mail(proxy_mail, dispatcher)
    @mail, @dispatcher = proxy_mail, dispatcher

    mail to: 'tech@shopbeam.com',
         cc: 'support@shopbeam.com',
         subject: "[order-manager:proxy-mailer] ACTION REQUIRED: Unknown mail"
  end

  def invalid_mail(proxy_mail, dispatcher, validator)
    @mail, @dispatcher, @validator = proxy_mail, dispatcher, validator.to_s.demodulize.titleize

    mail to: 'tech@shopbeam.com',
         cc: 'support@shopbeam.com',
         subject: "[order-manager:proxy-mailer] ACTION REQUIRED: Invalid mail"
  end

  private

  def proxy_mailer_layout
    case action_name
    when 'unknown_mail', 'invalid_mail'
      'proxy_mailer'
    else
      'mailer'
    end
  end
end
