module Checkout
  module Partners
    class WellCa < Base
      BASE_URL                          = 'https://well.ca/index.php?main_page='.freeze
      LOGIN_URL                         = "#{BASE_URL}login".freeze
      REGISTRATION_URL                  = "#{BASE_URL}create_account".freeze
      EMPTY_CART_URL                    = "#{BASE_URL}shopping_cart&action=remove_all".freeze
      ADDRESS_BOOK_URL                  = "#{BASE_URL}address_book".freeze
      ALTERNATE_ADDRESS_URL_PATTERN     = 'action=primary&address=(\d+)'.freeze
      ADDRESS_DELETE_CONFIRM_URL_FORMAT = "#{ADDRESS_BOOK_URL}_process&delete=%d&action=deleteconfirm".freeze
      CHECKOUT_URL                      = "#{BASE_URL}checkout_shipping".freeze
      CHECKOUT_SKIP_RECOMMENDATIONS_URL = "#{BASE_URL}checkout_shipping&recommended=true".freeze
      CHECKOUT_RECOMMENDATIONS_SLUG     = 'checkout_recommended_products'.freeze
      CHECKOUT_SKIP_SAMPLES_URL         = "#{BASE_URL}checkout_shipping&samples=no_thanks".freeze
      CHECKOUT_SAMPLES_SLUG             = 'checkout_samples'.freeze
      NEW_ADDRESS_SLUG                  = 'address_book_process'.freeze
      EDIT_SHIPPING_ADDRESS_URL         = "#{BASE_URL}checkout_shipping_address".freeze
      EDIT_BILLING_ADDRESS_URL          = "#{BASE_URL}checkout_payment_address".freeze

      def purchase
        browser.open do
          browser.goto session.product_url
          close_subscription_popup

          if new_user?
            sign_up
          else
            sign_in
            empty_cart
            delete_alternate_addresses
          end

          browser.goto session.product_url
          add_to_cart
          browser.goto CHECKOUT_URL
          skip_recommendations
          skip_samples
          fill_shipping_address
          fill_billing_info
          confirm
        end
      end

      private

      def close_subscription_popup
        begin
          browser
            .element(css: "[aria-labelledby='ui-dialog-title-newsletter_subscribe_auto']")
            .tap(&:wait_until_present)
            .element(class: 'ui-dialog-titlebar-close')
            .click
        rescue Watir::Wait::TimeoutError; end
      end

      def sign_up
        browser.goto REGISTRATION_URL
        browser.radio(name: 'gender', value: 'o').set
        browser.text_field(name: 'firstname').set proxy_user.first_name
        browser.text_field(name: 'lastname').set proxy_user.last_name
        browser.select(name: 'dob_year').select(DateTime.now.year - 25)
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.text_field(name: 'confirmation').set proxy_user.password
        browser.input(type: 'submit', value: /join/i).click

        on_error do |message|
          raise InvalidAccountError, message
        end

        proxy_user.save!
      end

      def sign_in
        browser.goto LOGIN_URL
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.input(type: 'submit', value: /sign in/i).click

        on_error do |message|
          raise InvalidAccountError, message
        end
      end

      def empty_cart
        if browser.element(id: 'header-shopping-cart-count').text != '0'
          browser.goto EMPTY_CART_URL
        end
      end

      def delete_alternate_addresses
        browser.goto ADDRESS_BOOK_URL
        browser.links(href: /#{ALTERNATE_ADDRESS_URL_PATTERN}/)
          .map { |link|
            address_id = link.href.match(/#{ALTERNATE_ADDRESS_URL_PATTERN}/)[1]
            ADDRESS_DELETE_CONFIRM_URL_FORMAT % address_id
          }.each { |url|
            browser.goto url
          }
      end

      def add_to_cart
        form = browser.form(name: 'cart_quantity')
        price = browser.element(class: 'product_text_price').text.gsub(/[$,]/, '').to_f * 100

        unless form.exists?
          raise ItemOutOfStockError
        end

        form.text.match(/max.*(\d+)/i) do |match|
          if match[1].to_i < session.product_quantity
            raise ItemOutOfStockError
          end
        end

        if price > session.product_price
          raise ItemPriceMismatchError
        end

        browser.text_field(id: 'cart_quantity').set session.product_quantity
        browser.element(id: 'add_to_cart_button').click
        browser.element(id: 'shopping-cart-dropdown').wait_until_present
      end

      def skip_recommendations
        if browser.url.include? CHECKOUT_RECOMMENDATIONS_SLUG
          browser.goto CHECKOUT_SKIP_RECOMMENDATIONS_URL
        end
      end

      def skip_samples
        if browser.url.include? CHECKOUT_SAMPLES_SLUG
          browser.goto CHECKOUT_SKIP_SAMPLES_URL
        end
      end

      def fill_shipping_address
        unless browser.url.include? NEW_ADDRESS_SLUG
          browser.goto EDIT_SHIPPING_ADDRESS_URL
        end

        fill_address shipping_address
        browser.input(type: 'submit', value: /submit|update/i).click

        on_error do |message|
          raise InvalidShippingAddressError, message
        end

        continue_btn = browser.input(type: 'submit', value: /\Acontinue\z/i)

        if continue_btn.exists?
          continue_btn.click
        else
          raise InvalidShippingInfoError
        end
      end

      def fill_billing_info
        fill_billing_address
        fill_payment_info

        continue_btn = browser.buttons(value: /\Acontinue\z/i).last
        continue_btn.click
        continue_btn.wait_while_present
        browser.body.wait_until_present

        on_error do |message|
          raise InvalidBillingInfoError, message
        end
      end

      def confirm
        browser.input(type: 'submit', value: /confirm/i).click

        on_error do |message|
          raise UnknownError, message
        end
      end

      def fill_billing_address
        browser.goto EDIT_BILLING_ADDRESS_URL
        fill_address billing_address
        browser.input(type: 'submit', value: /submit|update/i).click

        on_error do |message|
          raise InvalidBillingAddressError, message
        end
      end

      def fill_payment_info
        browser.radio(name: 'payment', value: 'eselect_api').set
        browser.text_field(name: 'eselect_api_cc_owner').set session.cc[:name]
        iframe = browser.iframe(id: 'eselect_api_cc_number')
        iframe.text_field(id: 'monerisDataInput').set session.cc[:number]
        iframe.text_field(id: 'monerisCVDInput').set session.cc[:cvv]
        browser
          .select(name: 'eselect_api_cc_expires_month')
          .select_value session.cc[:expiration_month].to_s.rjust(2, '0')
        browser
          .select(name: 'eselect_api_cc_expires_year')
          .select session.cc[:expiration_year]
        browser.checkbox(name: 'eselect_api_vault_save_cc').clear
      end

      def fill_address(data)
        browser.radio(name: 'gender', value: data[:gender]).set
        browser.text_field(name: 'firstname').set data[:first_name]
        browser.text_field(name: 'lastname').set data[:last_name]
        browser.text_field(name: 'street_address').set data[:address1]
        browser.text_field(name: 'suburb').set data[:address2]
        browser.text_field(name: 'city').set data[:city]
        browser.select(name: 'state').select data[:state]
        browser.text_field(name: 'postcode').set data[:zip]
        browser.select(name: 'country').select data[:country]
      end

      def shipping_address
        session.shipping_address.merge({
          state: to_state(session.shipping_address[:state]),
          country: 'Canada'
        })
      end

      def billing_address
        # TODO: Canada is not only a country to bill, fill an actual address here
        session.billing_address.merge({
          state: to_state(session.billing_address[:state]),
          country: 'Canada'
        })
      end

      def to_state(code)
        states = Hash[[
          ['AB', 'Alberta'],
          ['BC', 'British Columbia'],
          ['MB', 'Manitoba'],
          ['NB', 'New Brunswick'],
          ['NL', 'Newfoundland'],
          ['NT', 'Northwest Territories'],
          ['NS', 'Nova Scotia'],
          ['NU', 'Nunavut'],
          ['ON', 'Ontario'],
          ['PE', 'Prince Edward Island'],
          ['QC', 'Quebec'],
          ['SK', 'Saskatchewan'],
          ['YT', 'Yukon Territory']
        ]]

        states.default = states.values.first
        states[code]
      end

      def on_error
        alert = browser.alert
        error = browser.element(class: 'error')

        return yield alert.text if alert.exists?
        return yield error.text if error.exists?
      end
    end
  end
end
