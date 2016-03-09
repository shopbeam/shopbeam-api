steps_for :advertisingweek_eu_sign_up do
  step 'I go to registration page' do
    @browser.goto Checkout::AdvertisingweekEu::Bot::REGISTRATION_URL
  end

  step 'I fill first name' do
    @browser.text_field(name: 'register[firstname]').set 'John'
  end

  step 'I fill last name' do
    @browser.text_field(name: 'register[lastname]').set 'Doe'
  end

  step 'I fill company' do
    @browser.text_field(name: 'register[company]').set 'Shopbeam'
  end

  step 'I fill job title' do
    @browser.text_field(name: 'register[job_title]').set 'QA'
  end

  step 'I select job role' do
    @browser.select(name: 'register[user_job_role_id]').select 'Other'
  end

  step 'I select company activity' do
    @browser.select(name: 'register[user_company_activity_id]').select 'Other'
  end

  step 'I fill mobile phone' do
    @browser.text_field(name: 'register[mobile_phone]').set '1234567890'
  end

  step 'I do not participate in the networking program' do
    @browser.checkbox(name: 'register[awconnect]').clear
  end

  step 'I do not receive updates' do
    @browser.checkbox(name: 'register[sms_opt_out]').clear
  end

  step 'I fill email address' do
    @browser.text_field(name: 'register[email]').set 'john-doe-5e4c@orders.shopbeam.com'
  end

  step 'I fill password' do
    @browser.text_field(name: 'register[web_password]').set '8ae18fc563cb'
  end

  step 'I fill password confirmation' do
    @browser.text_field(name: 'register[web_passwordconfirm]').set '8ae18fc563cb'
  end

  step 'I should see submit button' do
    expect(@browser.link(class: 'register-button')).to be_present
  end
end
