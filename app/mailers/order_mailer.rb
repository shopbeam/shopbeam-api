class OrderMailer < ApplicationMailer
  layout false

  def received(order_id)
    @order = Order.find(order_id).decorate

    stage = Rails.configuration.x.stage
    themes_to_suppress = %w(advertisingweek healthy-essentials rogaine)

    subject = "Your Shopbeam order is being processed -- Order ##{@order.id}"
    subject = "[#{stage.upcase}] #{subject}" unless stage.production?

    if @order.theme =~ Regexp.new(themes_to_suppress.join('|'))
      to = 'orders@shopbeam.com'
      bcc = nil
      subject = "[SUPPRESSED] #{subject}"
    else
      to = @order.user_email
      bcc = 'orders@shopbeam.com'
    end

    prepend_theme_path(@order.theme)

    mail from: 'Shopbeam Support <support@shopbeam.com>',
         to: to,
         bcc: bcc,
         subject: subject
  end
end
