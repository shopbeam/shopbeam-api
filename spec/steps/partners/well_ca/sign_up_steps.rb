steps_for :well_ca_sign_up do
  step 'I go to registration page' do
    @browser.goto Checkout::WellCa::Bot::REGISTRATION_URL
  end

  step 'I set gender' do
    @browser.radio(name: 'gender', value: 'o').set
  end

  step 'I fill firstname' do
    @browser.text_field(name: 'firstname').set 'first name'
  end

  step 'I fill lastname' do
    @browser.text_field(name: 'lastname').set 'last name'
  end

  step 'I set birthday' do
    @browser.select(name: 'dob_year').select(DateTime.now.year - 25)
  end

  step 'I fill email_address' do
    @browser.text_field(name: 'email_address').set 'some@example.com'
  end

  step 'I fill password' do
    @browser.text_field(name: 'password').set 'some_password'
  end

  step 'I fill password_confirmation' do
    @browser.text_field(name: 'confirmation').set 'some_password'
  end

  step 'I should see submit button' do
    expect(@browser.button(text: /join/i)).to be_present
  end
end
