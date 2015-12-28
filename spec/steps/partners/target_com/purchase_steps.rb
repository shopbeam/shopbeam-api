steps_for :target_com_purchase do
  step 'there are the following products:' do |table|
    @products = table.hashes.map do |hash|
      double(
        source_url: hash['Source URL'],
        quantity: hash['Quantity'].to_i,
        sale_price_cents: hash['Sale price cents'].to_i,
        color: hash['Color'],
        size: hash['Size']
      )
    end
  end

  step 'I go to landing page' do
    @bot.send(:goto_landing)
  end

  step 'I go to checkout page' do
    @bot.send(:goto_checkout)
  end

  step 'I sign up as guest' do
    @bot.send(:sign_up_as_guest)
  end

  step 'I fill shipping address' do
    @bot.send(:fill_shipping_address)
  end

  step 'I fill billing info' do
    @bot.send(:fill_billing_info)
  end

  step 'I confirm order' do
    # Expect it to fail because of the test credit card number
    error_message = /There was a problem processing your payment/
    expect { @bot.send(:confirm_order) }.to raise_error(Checkout::ConfirmationError, error_message)
  end
end
