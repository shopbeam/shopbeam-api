module Checkout
  module TargetCom
    class Bot < BotBase
      BASE_URL = 'http://www.target.com/'.freeze

      def purchase!(items)
        super do
          goto_landing

          items.each do |item|
            add_to_cart(item)
          end

          goto_checkout
          sign_up_as_guest
          fill_shipping_address
          fill_billing_info
          confirm_order
        end
      end

      private

      def goto_landing
        browser.goto BASE_URL

        browser.element(class: 'bfx-wm-dialog').when_present do |dialog|
          dialog.link(id: 'leaveIntl').click
        end
      rescue Watir::Wait::TimeoutError
        # No popup, proceed
      end

      def add_to_cart(item)
        super do
          browser.element(class: 'pdpOneButtonLoader').wait_while_present

          select_color(item) if item.color.present?
          select_size(item) if item.size.present?

          ensure_availability(item)

          price_cents = browser.element(css: '[itemprop="price"]').text.gsub('$', '').to_f * 100

          ensure_price_match(item, price_cents)

          browser.text_field(class: 'quantityInput').set item.quantity

          # Do not use `browser.click_on` here
          # because `jQuery.active` counter is always non-zero on this page
          add_to_cart_btn.click

          on_error do |message|
            raise ItemOutOfStockError.new(
              url: item.source_url,
              requested_qty: item.quantity,
              actual_qty: message
            )
          end
        end
      end

      def goto_checkout
        browser.element(id: 'addtocart').when_present do |dialog|
          dialog.element(id: 'checkOutLink').click
        end

        browser.click_on browser.element(id: 'cartCheckout-2')
      end

      def sign_up_as_guest
        browser.click_on browser.link(id: 'newguest-submit')
      end

      def fill_shipping_address
        fill_address(session.shipping_address)
        browser.click_on browser.button(id: 'shipping-submit')

        on_error do |message|
          raise InvalidAddressError.new(browser.url, message)
        end

        browser.element(id: 'addressVerification').when_present do |dialog|
          browser.click_on dialog.button(class: 'useadr')
        end
      end

      def fill_billing_info
        browser.checkbox(name: 'payWithCreditcard').set

        fill_billing_address
        fill_payment_info

        browser.click_on browser.button(id: 'payment-submit')

        on_error do |message|
          raise InvalidBillingInfoError.new(browser.url, message)
        end
      end

      def confirm_order
        browser.text_field(name: 'email1').set proxy_user.user_email

        browser.click_on browser.button(id: 'order-submit')

        on_error('server-error') do |message|
          raise ConfirmationError.new(browser.url, message)
        end
      end

      def ensure_availability(item)
        unless add_to_cart_btn.present? && add_to_cart_btn.enabled?
          raise VariantNotAvailableError.new(browser.url, item)
        end
      end

      def add_to_cart_btn
        browser.button(id: 'addToCart')
      end

      def select_color(item)
        color = browser.radio(id: /\A#{item.color}\z/i)

        unless color.exists?
          raise VariantNotAvailableError.new(browser.url, item)
        end

        # Do not use `browser.wait_for_ajax` here
        # because `jQuery.active` counter is always non-zero on this page
        Watir::Wait.until do
          color.click
          color.element(xpath: '../self::li').class_name.include?('selected')
        end
      end

      def select_size(item)
        size = browser.select(class: 'sizeSelection').option(value: item.size)

        unless size.present?
          raise VariantNotAvailableError.new(browser.url, item)
        end

        size.select
        sleep 1 # wait for select list to be refreshed
      end

      def fill_billing_address
        browser.click_on browser.link(id: 'billingadredit').when_present
        fill_address(billing_address)
        browser.select(name: 'country').select_value billing_address[:country]

        browser.click_on browser.button(class: 'saveandContinue')

        on_error do |message|
          raise InvalidAddressError.new(browser.url, message)
        end
      end

      def fill_payment_info
        browser.text_field(name: 'cardNumber').set session.cc[:number]
        browser.select(name: 'expiryMonth').select_value session.cc[:expiration_month]
        browser.select(name: 'expiryYear').select_value session.cc[:expiration_year]
        sleep 1 # wait for cvv field to be refreshed
        browser.text_field(name: 'cvv').set session.cc[:cvv]
        browser.text_field(name: 'cardName').set session.cc[:name]
      end

      def fill_address(data)
        super() do
          browser.text_field(name: 'firstName').set data[:first_name]
          browser.text_field(name: 'lastName').set data[:last_name]
          browser.text_field(name: 'address1').set data[:address1]
          browser.text_field(name: 'address2').set data[:address2]
          browser.text_field(name: 'city').set data[:city]
          browser.select(name: 'state').select_value data[:state]
          browser.text_field(name: 'zipCode').set data[:zip]
          browser.text_field(name: 'phone1').set data[:phone]
        end
      end

      def billing_address
        @billing_address ||= session.billing_address.merge({
          country: 'US'
        })
      end

      def on_error(error_class = nil)
        errors = browser.elements(class: error_class || 'error-msg').select(&:visible?)

        if errors.any?
          message = errors.map(&:text).join("\n")
          return yield message if message.present?
        end

        error = browser.element(class: error_class || 'errorBlock')

        return yield error.text if error.present?
      end
    end
  end
end
