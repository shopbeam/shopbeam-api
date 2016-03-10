steps_for :advertisingweek_eu_purchase do
  step 'there are the following passes:' do |table|
    @products = table.hashes.map do |hash|
      double(
        source_url: hash['Source URL'],
        quantity: hash['Quantity'].to_i,
        price_cents: hash['Price cents'].to_i,
        size: hash['Size']
      )
    end
  end

  step 'I am registered user' do
    allow(@session).to receive_messages(
      customer_first_name: 'John',
      customer_last_name: 'Doe',
      customer_company: 'Shopbeam',
      customer_job_title: 'QA',
      customer_mobile_phone: '1234567890',
      customer_email: 'john-doe-5e4c@orders.shopbeam.com',
      customer_password: '8ae18fc563cb'
    )
  end

  step 'I go to landing page' do
    @browser.goto Checkout::AdvertisingweekEu::Bot::BASE_URL
  end

  step 'I sign in' do
    @bot.send(:sign_in)
  end

  step 'I empty cart' do
    @bot.send(:empty_cart)
  end

  step 'I go to checkout page' do
    @bot.send(:goto_checkout)
  end

  step 'I fill attendee info' do
    @bot.send(:fill_attendee_info)
  end

  step 'I go to payment page' do
    @bot.send(:goto_payment)
  end

  step 'I fill billing info' do
    @bot.send(:fill_billing_info)
  end

  step 'I confirm order' do
    # Expect it to fail because of the test credit card number
    error_message = /the credit card or expiration date you entered is invalid/
    expect { @bot.send(:confirm_order) }.to raise_error(Checkout::ConfirmationError, error_message)
  end
end
