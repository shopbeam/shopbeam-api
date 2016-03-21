class OrderMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(order)
    @order = order

    mail subject: "[order-manager] Shopbeam order ##{@order.id} has been successfully completed"
  end

  def completed_with_error(order, exception)
    @order = order
    @exception = exception

    attach_exception(exception)

    mail subject: "[order-manager] ACTION REQUIRED: Shopbeam order ##{@order.id} has been completed with error"
  end

  def not_found(order_id)
    @order_id = order_id

    mail subject: "[order-manager] Shopbeam order ##{@order_id} not found"
  end

  def terminated(order, exception)
    @order = order
    @exception = exception

    attach_exception(exception)

    mail subject: "[order-manager] ACTION REQUIRED: Shopbeam order ##{@order.id} has been terminated"
  end

  def terminated_with_error(order, error_code, error_message)
    bot_class = Checkout::Bots.lookup!(error_message)

    @proxy_user = order.proxy_user(bot_class.partner_type)

    return unless @proxy_user

    @error_code = error_code
    @error_title = error_title(error_code)

    mail to: @proxy_user.user_email,
         bcc: 'support@shopbeam.com',
         subject: @error_title do |format|
      format.html { render template: error_template(order, bot_class), layout: false }
    end
  rescue ActionView::MissingTemplate
    # Skip error mails for unsupported partners or themes
  end

  def aborted(order, exception)
    @order = order
    @exception = exception

    mail subject: "[order-manager] ACTION REQUIRED: Shopbeam order ##{@order.id} has been aborted"
  end

  def received(data)
    @data = data
    @order = data[:order]
    @user = data[:user]
    @items = data[:items]
    mail  subject: "Your Shopbeam order is being processed -- Order ##{@order.id}",
          template_name: 'order-default.html'
  end

  private

  def attach_exception(exception)
    attach_file(exception.try(:screenshot))
    attach_file(exception.try(:page_source))
  end

  def attach_file(path)
    return unless path

    filename = Pathname.new(path).basename.to_s
    attachments[filename] = File.read(path)
    File.unlink(path)
  end

  def error_title(error_code)
    case error_code
    when :item_out_of_stock
      'Out of Stock Item'
    when :invalid_address
      'Address Error'
    when :invalid_cc
      'Credit Card Error'
    else
      raise 'Unknown order error subject.'
    end
  end

  def error_template(order, bot_class)
    partner_path = bot_class.to_s.deconstantize.underscore
    theme = order.theme.underscore

    "#{partner_path}/templates/#{theme}/order_error.html.erb"
  end
end
