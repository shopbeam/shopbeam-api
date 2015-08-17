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

      def purchase
        browser.open do
          browser.goto session.product_url
          close_subscription_popup

          if new_user?
            sign_up
          else
            sign_in
            empty_cart
            browser.goto ADDRESS_BOOK_URL
            delete_alternate_addresses
          end

          browser.goto session.product_url
          add_to_cart
          browser.goto CHECKOUT_URL
          skip_recommendations
          skip_samples
        end
      end

      private

      def close_subscription_popup
        begin
          browser.element(css: "[aria-labelledby='ui-dialog-title-newsletter_subscribe_auto']")
            .tap(&:wait_until_present)
            .element(class: 'ui-dialog-titlebar-close')
            .click
        rescue TimeoutError; end
      end

      def sign_up
        browser.goto REGISTRATION_URL
        browser.radio(name: 'gender', value: 'o').set
        browser.text_field(name: 'firstname').set proxy_user.first_name
        browser.text_field(name: 'lastname').set proxy_user.last_name
        browser.select(name: 'dob_year').select(DateTime.now.year - 25).to_s
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.text_field(name: 'confirmation').set proxy_user.password
        browser.input(type: 'submit', value: /join/i).click
        proxy_user.save!
      end

      def sign_in
        browser.goto LOGIN_URL
        browser.text_field(name: 'email_address').set proxy_user.email
        browser.text_field(name: 'password').set proxy_user.password
        browser.input(type: 'submit', value: /sign in/i).click
      end

      def empty_cart
        if browser.element(id: 'header-shopping-cart-count').text != '0'
          browser.goto EMPTY_CART_URL
        end
      end

      def delete_alternate_addresses
        browser.links(href: /#{ALTERNATE_ADDRESS_URL_PATTERN}/)
          .map { |link|
            address_id = link.href.match(/#{ALTERNATE_ADDRESS_URL_PATTERN}/)[1]
            ADDRESS_DELETE_CONFIRM_URL_FORMAT % address_id
          }.each { |url|
            browser.goto url
          }
      end

      def add_to_cart
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
    end
  end
end
