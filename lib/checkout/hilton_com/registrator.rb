module Checkout
  module HiltonCom
    class Registrator < RegistratorBase
      REGISTRATION_URL = 'https://secure3.hilton.com/en/hh/customer/join/joinHHonors.htm'.freeze

      def register!
        browser.open do
          browser.goto REGISTRATION_URL

          form = browser.form(name: 'joinForm')

          form.text_field(name: 'firstName').set account.first_name
          form.text_field(name: 'lastName').set account.last_name
          form.text_field(name: 'phone').set account.phone_number
          form.text_field(name: 'email').set account.email
          form.select(name: 'countryCode').select_value account.country

          sleep 1 # wait for address fieldset to be shown

          fieldset = form.fieldset(class: 'fsAddressSetActive')

          fieldset.text_field(name: 'street1').set account.address1
          fieldset.text_field(name: 'street2').set account.address2
          fieldset.text_field(name: 'city').set account.city
          fieldset.select(name: 'state').select_value account.state
          fieldset.text_field(name: 'postalCode').set account.zip

          form.text_field(name: 'password').set account.password
          form.text_field(name: 'confirmPassword').set account.password

          form.checkboxes.select(&:visible?).each(&:set)

          browser.click_on form.button(text: /join hhonors/i)

          on_error do |message|
            raise InvalidAccountError.new(browser.url, message)
          end
        end
      end

      def on_error
        error = browser.element(class: 'errorListing')

        yield error.text if error.present?
      end
    end
  end
end
