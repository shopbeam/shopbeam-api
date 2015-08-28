class OrderMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(order)
    @order = order
    mail subject: "[order-manager] Shopbeam order ##{@order.id} has been successfully processed"
  end

  def terminated(order, exception)
    @order = order
    @exception = exception
    mail subject: "[order-manager] Shopbeam order ##{@order.id} has been terminated"
  end

  def aborted(order, exception)
    @order = order
    @exception = exception
    mail subject: "[order-manager] Shopbeam order ##{@order.id} has been aborted"
  end
end
