class ProxyMailer < ApplicationMailer
  include Roadie::Rails::Mailer

  # only/except options do not work in ActionMailer properly, use method instead
  layout :proxy_mailer_layout

  def forward(to:, proxy_mail:, **body)
    mail to: to,
         bcc: 'support@shopbeam.com',
         subject: proxy_mail.subject do |format|
      format.html { render html: body[:html].html_safe }
      format.text { render plain: body[:text] }
    end
  end

  def recipient_not_found(recipient)
    @recipient = recipient

    mail to: 'tech@shopbeam.com',
         cc: 'support@shopbeam.com',
         subject: "[order-manager:proxy-mailer] Recipient not found"
  end

  def unknown_mail(proxy_mail:, dispatcher:)
    @mail, @dispatcher = proxy_mail, dispatcher

    mail to: 'tech@shopbeam.com',
         cc: 'support@shopbeam.com',
         subject: "[order-manager:proxy-mailer] ACTION REQUIRED: Unknown mail"
  end

  def invalid_mail(proxy_mail:, dispatcher:, validator:, diff:)
    @mail, @dispatcher, @validator, @diff = proxy_mail, dispatcher, validator, diff

    roadie_mail to: 'tech@shopbeam.com',
                cc: 'support@shopbeam.com',
                subject: "Re: #{proxy_mail.subject}"
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
