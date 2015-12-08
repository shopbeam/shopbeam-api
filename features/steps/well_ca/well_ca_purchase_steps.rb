Before('@well_ca', '@purchase') do
  address = {
    gender: 'm',
    first_name: 'John',
    last_name: 'Smith',
    address1: '123 test st.',
    city: 'Toronto',
    state: 'ON',
    zip: 'A1A 1A1'
  }
  @bot = Checkout::WellCa::Bot.new(
    double(
      id: 1,
      shipping_address: address,
      billing_address: address,
      cc: {
        name: 'John Smith',
        number: '4444333322221111',
        cvv: '000',
        expiration_month: '01',
        expiration_year: Time.now.year + 5
      }
    )
  )
  @browser = @bot.send(:browser)
end

Given(/^the following products$/) do |table|
  @products = table.hashes.map do |hash|
    double(
      source_url: hash[:source_url],
      quantity: hash[:quantity].to_i,
      sale_price_cents: hash[:sale_price_cents].to_i,
      mark_as_out_of_stock!: true
    )
  end
end

Given(/^I am registered user$/) do
  user = double(email: 'john-doe-dae5@orders.shopbeam.com', password: '820af74d2d82')
  @bot.instance_variable_set(:@proxy_user, user)
end

When(/^I go to landing page$/) do
  @browser.goto Checkout::WellCa::Bot::BASE_URL
end

When(/^I sign in$/) do
  @bot.send(:sign_in)
end

When(/^I empty cart$/) do
  @bot.send(:empty_cart)
end

When(/^I remove alternate addresses$/) do
  @bot.send(:delete_alternate_addresses)
end

When(/^I remove samples$/) do
  @bot.send(:remove_samples, @products)

  items_in_cart = @browser.elements(class: 'shopping_cart_product_container')
  expect(items_in_cart.count).to eq(@products.count)
end

When(/^I go to checkout page$/) do
  @browser.goto Checkout::WellCa::Bot::CHECKOUT_URL
end

When(/^I skip recommendations$/) do
  @bot.send(:skip_recommendations)
end

When(/^I skip samples$/) do
  @bot.send(:skip_samples)
end

When(/^I fill shipping address$/) do
  @bot.send(:fill_shipping_address)
end

When(/^I fill billing info$/) do
  @bot.send(:fill_billing_info)
end

Then(/^I should see confirm button$/) do
  expect(@browser.button(text: /confirm/i)).to be_present
end
