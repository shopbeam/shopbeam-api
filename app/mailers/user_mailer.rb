class UserMailer < ApplicationMailer
  default bcc: 'support@shopbeam.com'

  def order_error(order, exception)
    # TODO: below is a really quick (and messy) solution, revise it!
    bot_class = Checkout::Bots.lookup!(exception.message)
    error_code = order_error_code(bot_class, exception.class)

    # Do not notify user about unsupported errors
    return unless error_code

    @user = order.user
    @proxy_user = @user.proxy_user(bot_class.partner_type)
    @error_title = order_error_title(bot_class, error_code)

    raise 'Unknown order error title' unless @error_title

    mail to: @user.email,
         subject: @error_title do |format|
      format.html { render template: order_error_template(order, bot_class, error_code), layout: false }
    end
  rescue ActionView::MissingTemplate
    # Skip error mails for unsupported partners or themes
  end

  private

  def order_error_code(bot_class, error_class)
    # TODO: encapsulate partner specific data into value object
    case bot_class.to_s
    when 'Checkout::AdvertisingweekEu::Bot'
      :default
    when 'Checkout::WellCa::Bot'
      case error_class.to_s
      when 'Checkout::VariantNotAvailableError',
           'Checkout::ItemOutOfStockError',
           'Checkout::ItemPriceMismatchError'
        :item_out_of_stock
      when 'Checkout::InvalidAddressError',
           'Checkout::InvalidShippingInfoError',
           'Checkout::InvalidBillingInfoError'
        :invalid_address
      when 'Checkout::ConfirmationError'
        :invalid_cc
      end
    end
  end

  def order_error_title(bot_class, error_code)
    # TODO: encapsulate partner specific data into value object
    case bot_class.to_s
    when 'Checkout::AdvertisingweekEu::Bot'
      'AWEurope Conference Registration Alert'
    when 'Checkout::WellCa::Bot'
      case error_code
      when :item_out_of_stock
        'Out of Stock Item'
      when :invalid_address
        'Address Error'
      when :invalid_cc
        'Credit Card Error'
      end
    end
  end

  def order_error_template(order, bot_class, error_code)
    # TODO: encapsulate partner specific data into value object
    partner_path = bot_class.to_s.deconstantize.underscore

    case bot_class.to_s
    when 'Checkout::AdvertisingweekEu::Bot'
      "#{partner_path}/templates/order_error_#{error_code}.html.erb"
    when 'Checkout::WellCa::Bot'
      "#{partner_path}/templates/#{order.theme.underscore}/order_error_#{error_code}.html.erb"
    end
  end
end
