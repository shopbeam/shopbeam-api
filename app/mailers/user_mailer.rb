class UserMailer < ApplicationMailer
  layout false

  def order_error(order, error_code, error_message)
    @order = order
    @error_code = error_code
    @error_message = error_message
    @error_title = order_error_title

    mail to: order.user_email,
         bcc: 'support@shopbeam.com',
         subject: @error_title do |format|
      format.html { render order_error_template }
    end
  rescue StandardError => exception
    OrderMailer.terminated(order, exception).deliver_now
  end

  private

  def order_error_title
    case @error_code
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

  def order_error_template
    partner_path = Checkout::Bots.lookup!(@error_message).to_s.deconstantize.underscore
    theme = @order.theme.underscore

    "#{partner_path}/templates/#{theme}/order_error.html.erb"
  end
end
