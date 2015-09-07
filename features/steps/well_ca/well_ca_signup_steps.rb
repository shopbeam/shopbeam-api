When(/^I go to registration page$/) do
  @browser = Checkout::Browser.new
  @browser.goto Checkout::Partners::WellCa::REGISTRATION_URL
end

Then(/^I set gender$/) do
  @browser.radio(name: 'gender', value: 'o').set
end

Then(/^I fill firstname$/) do
  @browser.text_field(name: 'firstname').set "first name"
end

Then(/^I fill lastname$/) do
  @browser.text_field(name: 'lastname').set "last name"
end

Then(/^I set birthday$/) do
  @browser.select(name: 'dob_year').select(DateTime.now.year - 25)
end

Then(/^I fill email_address$/) do
  @browser.text_field(name: 'email_address').set "some@example.com"
end

Then(/^I fill password$/) do
  @browser.text_field(name: 'password').set "some_password"
end

Then(/^I fill password_confirmation$/) do
  @browser.text_field(name: 'confirmation').set "some_password"
end

Then(/^I should see submit button$/) do
  button_visisble = @browser.input(type: 'submit', value: /join/i).present?
  expect(button_visisble).to be_truthy
end
