class CheckoutMailer < ApplicationMailer
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

  def aborted(order, exception)
    @order = order
    @exception = exception

    mail subject: "[order-manager] ACTION REQUIRED: Shopbeam order ##{@order.id} has been aborted"
  end

  def received(order_id)
    @order = Order.find(order_id).decorate

    mail subject: "Your Shopbeam order is being processed -- Order ##{@order.id}",
         template_name: 'order-default.html'
  end

  def publisher(data)
    @data = data
    @order = data[:order]
    @user = data[:user]
    @items = data[:items]
    @partner = data[:partner]
    mail  subject: "You\'ve made a sale with Shopbeam! -- Order ##{@order.id}",
          template_name: 'publisher_order.html'
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
end
