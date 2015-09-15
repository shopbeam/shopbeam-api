Given(/^registered user$/) do
  address = {
    state: 'AB',
    gender: 'm'}
  @partner = Checkout::Partners::WellCa.new(double(
    id: 1,
    shipping_address: address,
    billing_address: address,
    cc: {
      name: 'John Smith',
      number: '4444333322221111',
      cvv: '000',
      expiration_month: '01',
      expiration_year: 2020}))
  @browser = @partner.send(:browser)
  @user = double(email: "john-doe-dae5@orders.shopbeam.com", password: "820af74d2d82")
  @partner.instance_variable_set(:@proxy_user, @user)
  @items = [
    double(
      source_url: 'https://well.ca/products/skip-hop-zoo-packs-little-kid_89736.html',
      quantity: 1,
      sale_price_cents: 2499
    )
  ]
end

When(/^I go to landing page$/) do
  @browser.goto Checkout::Partners::WellCa::BASE_URL
end

Then(/^I close subscription popup$/) do
  @partner.send(:close_subscription_popup)
end

Then(/^I sign in$/) do
  @partner.send(:sign_in)
end

Then(/^I empty cart$/) do
  @partner.send(:empty_cart)
end

Then(/^I remove alternate addresses$/) do
  @partner.send(:delete_alternate_addresses)
end

Then(/^I add items to cart$/) do
  @items.each do |item|
    @partner.send(:add_to_cart, item)
  end
end

Then(/^I remove samples$/) do
  @partner.send(:remove_samples, @items)

  items_in_cart = @browser.elements(class: 'shopping_cart_product_container')
  expect(items_in_cart.count).to eq(@items.count)
end

Then(/^I go to checkout page$/) do
  @browser.goto Checkout::Partners::WellCa::CHECKOUT_URL
end

Then(/^I skip recomendations$/) do
  @partner.send(:skip_recommendations)
end

Then(/^I skip samples$/) do
  @partner.send(:skip_samples)
end

Then(/^I fill shipping address$/) do
  @partner.send(:fill_shipping_address)
end

Then(/^I fill billing info$/) do
  @partner.send(:fill_billing_info)
end

Then(/^I should see confirm button$/) do
  button_visible = @browser.input(type: 'submit', value: /confirm/i).present?
  expect(button_visible).to be_truthy
end
