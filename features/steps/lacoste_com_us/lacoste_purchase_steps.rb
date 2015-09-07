When(/^I go to landing page$/) do
  address = {
    state: 'CA',
    first_name: "John",
    last_name: "Smith",
    address1: "1 Infinite Loop",
    address2: "Cupertino, CA 95014",
    zip: 95014,
    city: "Cupertino"}
  @partner = Checkout::Partners::LacosteComUs.new(double(
    id: 1,
    shipping_address: address,
    billing_address: address,
    cc: {
      name: 'John Smith',
      number: '4444333322221111',
      cvv: '000',
      brand: :visa,
      expiration_month: '1',
      expiration_year: 2020}))
  @browser = @partner.send(:browser)
  @user = double(user_email: "john-doe-dae5@checkout.shopbeam.com", first_name: "Alex", last_name: "Bond")
  @partner.instance_variable_set(:@proxy_user, @user)

  @browser.goto Checkout::Partners::LacosteComUs::BASE_URL
end

Then(/^I add item to cart$/) do
  item = double(source_url: "http://www.lacoste.com/us/lacoste/men/clothing/polos/short-sleeve-original-heathered-pique-polo/L1264-51.html?dwvar_L1264-51_color=CCA",
                quantity: 1,
                sale_price_cents: 8950,
                color: 'CLOUD',
                size: 2)

  @partner.send(:add_to_cart, item)
end

Then(/^I go to checkout page$/) do
  @browser.goto Checkout::Partners::LacosteComUs::CHECKOUT_URL
end

Then(/^I signup as guest$/) do
  @partner.send(:sign_up_as_guest)
end

Then(/^I fill shipping info$/) do
  @partner.send(:fill_shipping_info)
end

Then(/^I fill billing address$/) do
  @partner.send(:fill_billing_address)
end

Then(/^I validate order$/) do
  @partner.send(:validate_order)
end

Then(/^I confirm order$/) do
  #we expect it fails due to test credit card number
  expected_error_text = "ConfirmationError: The following error(s) occurred on https://www.lacoste.com/us/checkout-validate: Error occured during the validation of your payment. Please try again."
  expect { @partner.send(:confirm_order) }.to raise_error(Checkout::ConfirmationError, expected_error_text)
end
