steps_for :hilton_com_sign_up do
  step 'I go to registration page' do
    @browser.goto Checkout::HiltonCom::Registrator::REGISTRATION_URL
  end

  step 'I fill first name' do
    @browser.text_field(name: 'firstName').set 'John'
  end

  step 'I fill last name' do
    @browser.text_field(name: 'lastName').set 'Smith'
  end

  step 'I fill phone number' do
    @browser.text_field(name: 'phone').set '1234567890'
  end

  step 'I fill email address' do
    @browser.text_field(name: 'email').set 'john@example.com'
  end

  step 'I select country' do
    @browser.select(name: 'countryCode').select_value 'US'
  end

  step 'I fill primary address' do
    @browser.fieldset(class: 'fsAddressSetActive').text_field(name: 'street1').set '1 Infinite Loop'
  end

  step 'I fill secondary address' do
    @browser.fieldset(class: 'fsAddressSetActive').text_field(name: 'street2').set 'Office 1'
  end

  step 'I fill city' do
    @browser.fieldset(class: 'fsAddressSetActive').text_field(name: 'city').set 'Cupertino'
  end

  step 'I select state' do
    @browser.fieldset(class: 'fsAddressSetActive').select(name: 'state').select_value 'CA'
  end

  step 'I fill postal code' do
    @browser.fieldset(class: 'fsAddressSetActive').text_field(name: 'postalCode').set 'CA 95014'
  end

  step 'I fill password' do
    @browser.text_field(name: 'password').set 'qwerty'
  end

  step 'I fill password confirmation' do
    @browser.text_field(name: 'confirmPassword').set 'qwerty'
  end

  step 'I accept terms and conditions' do
    @browser.checkbox(name: 'userAgreement').set
    @browser.checkbox(name: 'thirdParty').set
  end

  step 'I should see submit button' do
    expect(@browser.button(text: /join hhonors/i)).to be_present
  end
end
