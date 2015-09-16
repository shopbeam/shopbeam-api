Before('@well_ca', '@purchase') do
  address = {
    state: 'AB',
    gender: 'm'
  }
  @partner = Checkout::Partners::WellCa.new(
    double(
      id: 1,
      shipping_address: address,
      billing_address: address,
      cc: {
        name: 'John Smith',
        number: '4444333322221111',
        cvv: '000',
        expiration_month: '01',
        expiration_year: 2020
      }
    )
  )
  @browser = @partner.send(:browser)
end

Given(/^the following products$/) do |table|
  @products = table.hashes.map do |hash|
    double(
      source_url: hash[:source_url],
      quantity: hash[:quantity].to_i,
      sale_price_cents: hash[:sale_price_cents].to_i
    )
  end
end

Given(/^I am registered user$/) do
  user = double(email: 'john-doe-dae5@orders.shopbeam.com', password: '820af74d2d82')
  @partner.instance_variable_set(:@proxy_user, user)
end

When(/^I go to landing page$/) do
  @browser.goto Checkout::Partners::WellCa::BASE_URL
end

When(/^I close subscription popup$/) do
  @partner.send(:close_subscription_popup)
end

When(/^I sign in$/) do
  @partner.send(:sign_in)
end

When(/^I empty cart$/) do
  @partner.send(:empty_cart)
end

When(/^I remove alternate addresses$/) do
  @partner.send(:delete_alternate_addresses)
end

When(/^I add products to cart$/) do
  @products.each do |product|
    @partner.send(:add_to_cart, product)
  end
end

When(/^I remove samples$/) do
  @partner.send(:remove_samples, @products)

  items_in_cart = @browser.elements(class: 'shopping_cart_product_container')
  expect(items_in_cart.count).to eq(@products.count)
end

When(/^I go to checkout page$/) do
  @browser.goto Checkout::Partners::WellCa::CHECKOUT_URL
end

When(/^I skip recomendations$/) do
  @partner.send(:skip_recommendations)
end

When(/^I skip samples$/) do
  @partner.send(:skip_samples)
end

When(/^I fill shipping address$/) do
  @partner.send(:fill_shipping_address)
end

When(/^I fill billing info$/) do
  @partner.send(:fill_billing_info)
end

Then(/^I should see confirm button$/) do
  button_visible = @browser.input(type: 'submit', value: /confirm/i).present?
  expect(button_visible).to be_truthy
end
