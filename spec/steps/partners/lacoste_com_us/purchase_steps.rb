steps_for :lacoste_purchase do
  step 'there are the following products:' do |table|
    @products = table.hashes.map do |hash|
      double(
        source_url: hash['Source URL'],
        quantity: hash['Quantity'].to_i,
        price_cents: hash['Price cents'].to_i,
        color: hash['Color'],
        size: hash['Size']
      )
    end
  end

  step 'I go to checkout page' do
    @browser.goto Checkout::LacosteComUs::Bot::CHECKOUT_URL
  end

  step 'I sign up as guest' do
    user = double(
      user_email: 'john-doe-dae5@orders.shopbeam.com',
      first_name: 'John',
      last_name: 'Doe'
    )

    @bot.instance_variable_set(:@proxy_user, user)
    @bot.send(:sign_up_as_guest)
  end

  step 'I fill shipping info' do
    @bot.send(:fill_shipping_info)
  end

  step 'I fill billing address' do
    @bot.send(:fill_billing_address)
  end

  step 'I validate order' do
    @bot.send(:validate_order)
  end

  step 'I confirm order' do
    # Expect it to fail because of the test credit card number
    error_message = /Error occured during the validation of your payment|Holder name is not correct/
    expect { @bot.send(:confirm_order) }.to raise_error(Checkout::ConfirmationError, error_message)
  end
end
