Before('@lacoste', '@purchase') do
  address = {
    state: 'CA',
    first_name: 'John',
    last_name: 'Smith',
    address1: '1 Infinite Loop',
    address2: 'Cupertino, CA 95014',
    zip: 95014,
    city: 'Cupertino'
  }
  @partner = Checkout::Partners::LacosteComUs.new(
    double(
      id: 1,
      shipping_address: address,
      billing_address: address,
      cc: {
        name: 'John Smith',
        number: '4444333322221111',
        cvv: '000',
        brand: :visa,
        expiration_month: '1',
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
      sale_price_cents: hash[:sale_price_cents].to_i,
      color: hash[:color],
      size: hash[:size]
    )
  end
end

When(/^I add products to cart$/) do
  @products.each do |product|
    @partner.send(:add_to_cart, product)
  end
end

When(/^I go to checkout page$/) do
  @browser.goto Checkout::Partners::LacosteComUs::CHECKOUT_URL
end

When(/^I sign up as guest$/) do
  user = double(user_email: 'john-doe-dae5@checkout.shopbeam.com', first_name: 'Alex', last_name: 'Bond')
  @partner.instance_variable_set(:@proxy_user, user)
  @partner.send(:sign_up_as_guest)
end

When(/^I fill shipping info$/) do
  @partner.send(:fill_shipping_info)
end

When(/^I fill billing address$/) do
  @partner.send(:fill_billing_address)
end

When(/^I validate order$/) do
  @partner.send(:validate_order)
end

Then(/^I confirm order$/) do
  # Expect it to fail due to a test credit card number
  expected_error_text = 'ConfirmationError: The following error(s) occurred on https://www.lacoste.com/us/checkout-validate: Error occured during the validation of your payment. Please try again.'
  expect { @partner.send(:confirm_order) }.to raise_error(Checkout::ConfirmationError, expected_error_text)
end
