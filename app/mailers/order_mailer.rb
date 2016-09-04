class OrderMailer < ApplicationMailer
  layout false

  def received(order_id)
    @order = Order.find(order_id).decorate

    stage = Rails.configuration.x.stage
    subject = "Your Shopbeam order is being processed -- Order ##{@order.id}"
    subject = "[#{stage.upcase}] #{subject}" unless stage.production?

    if @order.theme =~ /(rogaine)|(healthy-essentials)|(advertisingweek)/
      to = 'orders@shopbeam.com'
      bcc = nil
      subject = "[SUPPRESSED] #{subject}"
    else
      to = @order.user_email
      bcc = 'orders@shopbeam.com'
    end

    mail from: 'Shopbeam Support <support@shopbeam.com>',
         to: to,
         bcc: bcc,
         subject: subject,
         template_path: template_path(@order.theme)
  end

  private

  def template_path(theme)
    theme_path = theme.underscore

    if template_exists?(File.join(controller_path, theme_path, action_name))
      File.join(controller_path, theme_path)
    else
      File.join(controller_path, 'default')
    end
  end
end
