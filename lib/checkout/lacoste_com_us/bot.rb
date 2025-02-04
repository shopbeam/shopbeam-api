module Checkout
  module LacosteComUs
    class Bot < BotBase
      BASE_URL     = 'https://www.lacoste.com/us/'.freeze
      CHECKOUT_URL = "#{BASE_URL}login-checkout".freeze

      def purchase!(items)
        super do
          items.each do |item|
            add_to_cart(item)
          end

          browser.goto CHECKOUT_URL
          sign_up_as_guest
          fill_shipping_info
          fill_billing_address
          validate_order
          confirm_order
        end
      end

      private

      def add_to_cart(item)
        super do
          ensure_availability(item)

          variations = browser.element(class: 'product-variations')

          select_color(item, variations) if item.color.present?
          select_size(item, variations) if item.size.present?

          ensure_availability(item)

          price_cents = browser.element(css: '[itemprop="price"]').attribute_value('textContent').to_f * 100

          ensure_price_match(item, price_cents)

          item.quantity.times do
            browser.click_on add_to_cart_btn
            browser.element(class: 'mini-cart')
              .tap(&:wait_until_present)
              .tap(&:wait_while_present)
          end
        end
      end

      def sign_up_as_guest
        browser.text_field(id: 'js-login-checkout-new-user-email').set proxy_user.user_email
        browser.click_on browser.button(id: 'js-express-order')

        on_error do |message|
          raise InvalidAccountError.new(browser.url, message)
        end
      end

      def fill_shipping_info
        browser.radio(name: 'shipping-method', value: 'Ground').set
        fill_shipping_address
      end

      def fill_billing_address
        browser.checkbox(id: 'sa-billingissame').clear
        fill_address(billing_address, 'ba')
      end

      def validate_order
        browser.click_on browser.button(text: /\Avalidate and review my order\z/i)

        on_error do |message|
          raise InvalidAddressError.new(browser.url, message)
        end

        browser.element(css: '.dialog.active').when_present do |dialog|
          if dialog.radio(name: 'address', value: 'found').present?
            browser.click_on dialog.button(id: 'acceptDavCheck')
          else
            raise InvalidAddressError.new(browser.url, dialog.ps.last.text)
          end
        end
      end

      def confirm_order
        browser.radio(name: 'add-payment-method', value: 'CREDIT_CARD').set
        browser.select(name: 'npm-type-card').select_value to_cc_brand(session.cc[:brand])
        browser.text_field(name: 'npm-holder-name').set session.cc[:name]
        browser.select(name: 'npm-expiry-date-month').select_value session.cc[:expiration_month]
        browser.select(name: 'npm-expiry-date-year').select_value session.cc[:expiration_year]
        browser.text_field(id: 'npm-card-number').set session.cc[:number]
        browser.text_field(id: 'npm-cryptogramme').set session.cc[:cvv]
        browser.checkbox(name: 'check-condition').set
        browser.click_on browser.button(text: /\Aconfirm my order\z/i)

        on_error do |message|
          raise ConfirmationError.new(browser.url, message)
        end

        # TODO: save order number, then enable Lacoste bot and mail dispatcher
      end

      def ensure_availability(item)
        unless add_to_cart_btn.present? && add_to_cart_btn.enabled?
          raise VariantNotAvailableError.new(browser.url, item)
        end
      end

      def add_to_cart_btn
        browser.button(id: 'add-to-cart')
      end

      def select_color(item, variations)
        color = browser.element(id: 'selectedColor', text: /\A#{item.color}\z/i)

        unless color.present?
          color = variations.element(class: 'color').link(title: /\A#{item.color}\z/i)

          unless color.present?
            raise VariantNotAvailableError.new(browser.url, item)
          end

          browser.click_on color
        end
      end

      def select_size(item, variations)
        sizes = variations.select(class: 'product-sizes')
        size = sizes.element(xpath: "//option[@value='#{item.size}' and not(@disabled)]")

        unless size.present?
          raise VariantNotAvailableError.new(browser.url, item)
        end

        browser.wait_for_ajax { sizes.select_value(size.value) }
      end

      def fill_shipping_address
        fill_address(shipping_address, 'sa')
      end

      def fill_address(data, prefix)
        super() do
          browser.radio(name: "#{prefix}-civility", value: data[:salutation]).set
          browser.text_field(name: "#{prefix}-first-name").set data[:first_name]
          browser.text_field(name: "#{prefix}-last-name").set data[:last_name]
          browser.text_field(name: "#{prefix}-number-and-street").set data[:address1]
          browser.text_field(name: "#{prefix}-complementary-information").set data[:address2]
          browser.text_field(name: "#{prefix}-zip-code").set data[:zip]
          browser.text_field(name: "#{prefix}-town").set data[:city]
          browser.select(name: "#{prefix}-country").select_value data[:country]
          browser.select(name: "#{prefix}-state").select_value data[:state]
        end
      end

      def shipping_address
        @shipping_address ||= session.shipping_address.merge({
          salutation: 'MR',
          country: 'US'
        })
      end

      def billing_address
        @billing_address ||= session.billing_address.merge({
          salutation: 'MR',
          country: 'US'
        })
      end

      def to_cc_brand(brand)
        cc_brands[brand] || (raise InvalidBillingInfoError.new(browser.url, "Credit card with type '#{brand}' not supported."))
      end

      def cc_brands
        @cc_brands ||= {
          visa: 'Visa',
          amex: 'Amex',
          master_card: 'MasterCard',
          discover: 'Discover'
        }
      end

      def on_error
        errors = browser.spans(class: 'error').select(&:visible?)

        if errors.any?
          message = errors.map(&:text).join("\n")
          yield message if message.present?
        end
      end
    end
  end
end
