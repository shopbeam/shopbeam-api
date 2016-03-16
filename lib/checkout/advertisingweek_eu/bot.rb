module Checkout
  module AdvertisingweekEu
    class Bot < BotBase
      BASE_URL         = 'https://advertisingweek.eu/'.freeze
      LOGIN_URL        = "#{BASE_URL}login".freeze
      REGISTRATION_URL = "#{BASE_URL}register/quick/".freeze
      EMPTY_CART_URL   = "#{BASE_URL}register/?clearsession=1".freeze

      def purchase!(items)
        super do
          browser.goto BASE_URL

          if new_user?
            sign_up
          else
            sign_in
            empty_cart
          end

          items.each do |item|
            add_to_cart(item)
          end

          goto_checkout
          fill_attendee_info
          goto_payment
          fill_billing_info
          confirm_order
        end
      end

      private

      def sign_up
        browser.goto REGISTRATION_URL
        browser.text_field(name: 'register[firstname]').set session.customer_first_name
        browser.text_field(name: 'register[lastname]').set session.customer_last_name
        browser.text_field(name: 'register[company]').set session.customer_company
        browser.text_field(name: 'register[job_title]').set session.customer_job_title
        browser.select(name: 'register[user_job_role_id]').select 'Other'
        browser.select(name: 'register[user_company_activity_id]').select 'Other'
        browser.text_field(name: 'register[mobile_phone]').set session.customer_mobile_phone
        browser.checkbox(name: 'register[awconnect]').clear
        browser.checkbox(name: 'register[sms_opt_out]').clear
        browser.text_field(name: 'register[email]').set session.customer_email
        browser.text_field(name: 'register[web_password]').set session.customer_password
        browser.text_field(name: 'register[web_passwordconfirm]').set session.customer_password
        # Scroll to bottom where the target link is accessible
        scroll_to_bottom
        browser.click_on browser.link(class: 'register-button')

        on_error do |message|
          if message =~ /Email already in use/i
            raise AccountExistsError.new(browser.url, session.customer_email)
          else
            raise InvalidAccountError.new(browser.url, message)
          end
        end

        proxy_user.save!
      end

      def sign_in
        browser.goto LOGIN_URL
        browser.text_field(name: 'login[username]').set session.customer_email
        browser.text_field(name: 'login[password]').set session.customer_password
        browser.click_on browser.link(class: 'login-button')

        on_error do |message|
          raise InvalidAccountError.new(browser.url, message)
        end
      end

      def empty_cart
        browser.goto EMPTY_CART_URL

        # Above clears the entire session, so sign in again
        sign_in
      end

      def add_to_cart(item)
        super do
          pass = browser.elements(class: 'register-addBasket').find do |p|
            p.element(class: 'display_name', text: /\A#{item.size}\z/i).present?
          end

          unless pass.present?
            raise VariantNotAvailableError.new(browser.url, item)
          end

          price_cents = pass.element(class: 'showcase-price').text.match(/[\d.]+/) do |match|
            match[0].to_f * 100
          end

          ensure_price_match(item, price_cents)
          pass.text_field(class: 'item_qty').set item.quantity
          browser.click_on pass.link(text: /add/i)
          browser.element(class: 'register-basket').wait_until_present
        end
      end

      def goto_checkout
        sleep 1 # wait for basket to be updated via js
        browser.click_on browser.element(class: 'register-basket').link(text: /Next Step/i)
        browser.click_on browser.element(class: 'modal').link(text: /no/i).when_present
        browser.click_on browser.link(text: /Next Step/i).when_present
      end

      def fill_attendee_info
        browser.checkbox(name: 'moduledata[1][is_mine]').clear
        browser.text_field(name: 'moduledata[1][data][extra][0][firstname]').set session.customer_first_name
        browser.text_field(name: 'moduledata[1][data][extra][0][lastname]').set session.customer_last_name
        browser.text_field(name: 'moduledata[1][data][extra][0][company]').set session.customer_company
        browser.text_field(name: 'moduledata[1][data][extra][0][job_title]').set session.customer_job_title
        browser.text_field(name: 'moduledata[1][data][extra][0][mobile_phone]').set session.customer_mobile_phone
        browser.text_field(name: 'moduledata[1][data][extra][0][email]').set session.customer_email
        browser.checkbox(name: 'moduledata[1][data][extra][0][concierge]').clear
        # Scroll to bottom where the target link is accessible
        scroll_to_bottom
        browser.click_on browser.form(name: 'items').link(text: /Next Step/i)

        on_error do |message|
          raise InvalidAccountError.new(browser.url, message)
        end
      end

      def goto_payment
        # Scroll to bottom where the target link is accessible
        scroll_to_bottom
        browser.click_on browser.form(name: 'items').link(text: /proceed to checkout/i)
      end

      def fill_billing_info
        fill_billing_address
        fill_payment_info
      end

      def confirm_order
        browser.click_on browser.form(name: 'payment').link(text: /process payment/i)

        iframe = payment_iframe

        # Wait for Braintree to process payment
        iframe.element(class: 'loader').wait_while_present

        if iframe.elements(class: 'invalid').any?
          raise InvalidBillingInfoError.new(browser.url, 'Invalid credit card.')
        end

        # Although Watir.always_locate? is true it cannot re-locate an element on use on this page
        # Touch body content to force DOM refresh
        browser.body.text

        on_error do |message|
          raise ConfirmationError.new(browser.url, message)
        end
      end

      def fill_billing_address
        fill_address do
          browser.text_field(name: 'data[transactions][0][firstname]').set session.customer_first_name
          browser.text_field(name: 'data[transactions][0][lastname]').set session.customer_last_name
          browser.text_field(name: 'data[transactions][0][email]').set session.customer_email
          browser.text_field(name: 'data[transactions][0][company]').set session.customer_company
          browser.text_field(name: 'data[transactions][0][phy_addr_01]').set billing_address[:address1]
          browser.text_field(name: 'data[transactions][0][phy_addr_02]').set billing_address[:address2]
          browser.text_field(name: 'data[transactions][0][phy_city]').set billing_address[:city]
          browser.text_field(name: 'data[transactions][0][phy_state]').set billing_address[:state]
          browser.text_field(name: 'data[transactions][0][phy_code]').set billing_address[:zip]
          browser.select(name: 'data[transactions][0][phy_country_id]').select billing_address[:country]
          browser.text_field(name: 'data[transactions][0][phone]').set billing_address[:phone]
        end
      end

      def fill_payment_info
        # Scroll to bottom where the target iframe is accessible
        scroll_to_bottom
        iframe = payment_iframe
        iframe.text_field(name: 'credit-card-number').set session.cc[:number]
        iframe.text_field(name: 'expiration').set "#{session.cc[:expiration_month]}#{session.cc[:expiration_year].to_s.last(2)}"
        iframe.text_field(name: 'cvv').set session.cc[:cvv]
        browser.checkbox(name: 'cc[confirm]').set
      end

      def billing_address
        @billing_address ||= session.billing_address.merge({
          country: ISO3166::Country.new(session.billing_address[:country]).try(:name)
        })
      end

      def scroll_to_bottom
        browser.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      end

      def payment_iframe
        browser.iframe(id: 'braintree-dropin-frame')
      end

      def on_error
        errors = browser.elements(xpath: "//*[contains(@class, 'alert-danger') or contains(@class, 'form-invalid')]").select(&:visible?)

        if errors.any?
          message = errors.map(&:text).join("\n")
          yield message if message.present?
        end
      end
    end
  end
end
