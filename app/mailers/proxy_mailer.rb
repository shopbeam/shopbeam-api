class ProxyMailer < ApplicationMailer
  def forward(options)
    mail to: options[:to],
         bcc: 'support@shopbeam.com',
         subject: options[:subject] do |format|
      format.html { render html: options[:body_html] }
      format.text { render plain: options[:body_plain] }
    end
  end

  def recipient_not_found(email)
    @email = email

    mail to: 'tech@shopbeam.com',
         subject: "[order-manager:proxy-mailer] Recipient with email '#{@email}' not found"
  end
end
