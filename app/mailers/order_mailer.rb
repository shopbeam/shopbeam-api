class OrderMailer < ApplicationMailer
  layout false

  def received(order_id)
    @order = Order.find(order_id).decorate

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

  def placed(order_id, user_id, order_item_ids, commission)
    user = User.find(user_id)
    order_items = OrderItem.find(order_item_ids)
    publisher = Publisher.new(user: user, order_items: order_items, commission: commission)

    @order = Order.find(order_id).decorate
    @publisher = PublisherDecorator.new(publisher)

    subject = "You've made a sale with Shopbeam! -- Order ##{@order.id}"
    subject = "[#{stage.upcase}] #{subject}" unless stage.production?

    mail from: 'Shopbeam Support <support@shopbeam.com>',
         to: @publisher.email,
         bcc: 'orders@shopbeam.com',
         subject: subject
  end

  private

  def stage
    Rails.configuration.x.stage
  end
end
