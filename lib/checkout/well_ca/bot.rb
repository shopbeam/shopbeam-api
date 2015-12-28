module Checkout
  module WellCa
    class Bot < BotBase
      BASE_URL                          = 'https://well.ca/index.php?main_page='.freeze
      LOGIN_URL                         = "#{BASE_URL}login".freeze
      REGISTRATION_URL                  = "#{BASE_URL}create_account".freeze
      CART_URL                          = "#{BASE_URL}shopping_cart".freeze
      EMPTY_CART_URL                    = "#{CART_URL}&action=remove_all".freeze
      REMOVE_PRODUCT_URL_PATTERN        = /action=remove_product&product_id=(\d+)/.freeze
      ADDRESS_BOOK_URL                  = "#{BASE_URL}address_book".freeze
      ALTERNATE_ADDRESS_URL_PATTERN     = /action=primary&address=(\d+)/.freeze
      ADDRESS_DELETE_CONFIRM_URL_FORMAT = "#{ADDRESS_BOOK_URL}_process&delete=%d&action=deleteconfirm".freeze
      CHECKOUT_URL                      = "#{BASE_URL}checkout_shipping".freeze
      CHECKOUT_SKIP_RECOMMENDATIONS_URL = "#{BASE_URL}checkout_shipping&recommended=true".freeze
      CHECKOUT_RECOMMENDATIONS_SLUG     = 'checkout_recommended_products'.freeze
      CHECKOUT_SKIP_SAMPLES_URL         = "#{BASE_URL}checkout_shipping&samples=no_thanks".freeze
      CHECKOUT_SAMPLES_SLUG             = 'checkout_samples'.freeze
      NEW_ADDRESS_SLUG                  = 'address_book_process'.freeze
      EDIT_SHIPPING_ADDRESS_URL         = "#{BASE_URL}checkout_shipping_address".freeze
      EDIT_BILLING_ADDRESS_URL          = "#{BASE_URL}checkout_payment_address".freeze
      ORDER_NUMBER_PATTERN              = /your order number is:\s*(\w+)/i.freeze

      def purchase!(items)
        super do
          browser.goto BASE_URL

          if new_user?
            sign_up
          else
            sign_in
            empty_cart
            delete_alternate_addresses
          end

          items.each do |item|
            add_to_cart(item)
          end

          remove_samples(items)
          browser.goto CHECKOUT_URL
          skip_recommendations
          skip_samples
          fill_shipping_address
          fill_billing_info
          confirm_order
        end
      end

      private

      def sign_up
        browser.goto REGISTRATION_URL
        browser.radio(name: 'gender', value: 'o').set
        browser.text_field(name: 'firstname').set proxy_user.first_name
        browser.text_field(name: 'lastname').set proxy_user.last_name
        browser.select(name: 'dob_year').select(DateTime.now.year - 25)
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.text_field(name: 'confirmation').set proxy_user.password
        browser.click_on browser.button(text: /join/i)

        on_error do |message|
          raise InvalidAccountError.new(browser.url, message)
        end

        proxy_user.save!
      end

      def sign_in
        browser.goto LOGIN_URL
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.click_on browser.button(text: /sign in/i)

        on_error(LOGIN_URL) do |message|
          raise InvalidAccountError.new(browser.url, message)
        end
      end

      def empty_cart
        browser.goto EMPTY_CART_URL if cart_count > 0
      end

      def delete_alternate_addresses
        browser.goto ADDRESS_BOOK_URL
        browser.links(href: ALTERNATE_ADDRESS_URL_PATTERN)
          .map { |link|
            address_id = link.href.match(ALTERNATE_ADDRESS_URL_PATTERN)[1]
            sprintf(ADDRESS_DELETE_CONFIRM_URL_FORMAT, address_id)
          }.each { |url|
            browser.goto url
          }
      end

      def add_to_cart(item)
        super do
          ensure_availability(item)

          product_notes = browser.elements(class: 'productNotes').last

          if product_notes.present?
            product_notes.text.match(/(?=max|stock).*(\d+)/i) do |match|
              if match[1].to_i < item.quantity
                raise ItemOutOfStockError.new(
                  url: item.source_url,
                  requested_qty: item.quantity,
                  actual_qty: match[1]
                )
              end
            end
          end

          price_cents = browser.element(class: 'currentPrice').text.gsub(/[$,]/, '').to_f * 100

          ensure_price_match(item, price_cents)

          browser.text_field(id: 'cart_quantity').set item.quantity
          browser.click_on browser.button(id: 'add_to_cart_button')
          browser.element(id: 'shopping-cart-table').wait_until_present
        end
      end

      def remove_samples(items)
        items_list = items.map(&:source_url)

        browser.goto CART_URL

        browser.elements(class: 'shopping_cart_product_container')
          .each_with_object([]) { |container, links|
            item_link = container.element(class: 'name').link.href

            unless item_link.in?(items_list)
              links << container.link(href: REMOVE_PRODUCT_URL_PATTERN).href
            end
          }.each { |url|
            browser.goto url
          }
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

        fill_address(shipping_address)
        browser.form(name: /addressbook|checkout_address/).submit

        on_error do |message|
          raise InvalidAddressError.new(browser.url, message)
        end

        continue_btn = browser.links(class: 'btn-pink', text: /\Acontinue\z/i).last

        if continue_btn.present?
          browser.click_on continue_btn
        else
          raise InvalidShippingInfoError.new(browser.url, 'Invalid shipping info.')
        end
      end

      def fill_billing_info
        fill_billing_address
        fill_payment_info

        continue_btn = browser.links(class: 'btn-pink', text: /\Acontinue\z/i).last
        browser.click_on continue_btn

        # Wait for page with 3rd party iframe to reload
        continue_btn.wait_while_present
        browser.body.wait_until_present

        on_error do |message|
          raise InvalidBillingInfoError.new(browser.url, message)
        end
      end

      def confirm_order
        browser.click_on browser.buttons(text: /confirm/i).last

        on_error do |message|
          raise ConfirmationError.new(browser.url, message)
        end

        save_order_number
      end

      def ensure_availability(item)
        unless browser.form(name: 'cart_quantity').present?
          raise VariantNotAvailableError.new(browser.url, item)
        end
      end

      def cart_count
        browser.element(id: 'header-shopping-cart-count').text.to_i
      end

      def fill_billing_address
        browser.goto EDIT_BILLING_ADDRESS_URL
        fill_address(billing_address)
        browser.click_on browser.buttons(text: /submit|update/i).last

        on_error do |message|
          raise InvalidAddressError.new(browser.url, message)
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
        super() do
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
      end

      def save_order_number
        order_number = browser.element(class: 'checkout_ref_num')

        unless order_number.present?
          raise "Unable to locate element #{order_number.inspect}."
        end

        unless ORDER_NUMBER_PATTERN =~ order_number.text
          raise "Unable to find order number in #{order_number.text}."
        end

        session.save_reference!(partner_type, Regexp.last_match(1))
      rescue StandardError => exception
        raise InvalidOrderNumberError.new(browser.url, exception.message)
      end

      def shipping_address
        @shipping_address ||= session.shipping_address.merge({
          gender: 'm',
          state: to_state(session.shipping_address[:state]),
          country: 'Canada'
        })
      end

      def billing_address
        @billing_address ||= session.billing_address.merge({
          gender: 'm',
          state: to_state(session.billing_address[:state]),
          country: 'Canada'
        })
      end

      def to_state(code)
        states[code] || (raise InvalidAddressError.new(browser.url, "State with code '#{code}' not supported."))
      end

      def states
        @states ||= Hash[[
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
      end

      def on_error(url = nil)
        return if url && !browser.on_page?(url)

        alert = browser.alert

        if alert.present?
          message = alert.text
          alert.close
          return yield message
        end

        error = browser.element(class: 'messageStackError')

        yield error.text if error.present?
      end
    end
  end
end
