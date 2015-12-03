Before('@well_ca', '@sign_up') do
  partner = Checkout::WellCa::Bot.new(double(id: 1))
  @browser = partner.send(:browser)
end

When(/^I go to registration page$/) do
  @browser.goto Checkout::WellCa::Bot::REGISTRATION_URL
end

When(/^I set gender$/) do
  @browser.radio(name: 'gender', value: 'o').set
end

When(/^I fill firstname$/) do
  @browser.text_field(name: 'firstname').set "first name"
end

When(/^I fill lastname$/) do
  @browser.text_field(name: 'lastname').set "last name"
end

When(/^I set birthday$/) do
  @browser.select(name: 'dob_year').select(DateTime.now.year - 25)
end

When(/^I fill email_address$/) do
  @browser.text_field(name: 'email_address').set "some@example.com"
end

When(/^I fill password$/) do
  @browser.text_field(name: 'password').set "some_password"
end

When(/^I fill password_confirmation$/) do
  @browser.text_field(name: 'confirmation').set "some_password"
end

Then(/^I should see submit button$/) do
  expect(@browser.button(text: /join/i)).to be_present
end
