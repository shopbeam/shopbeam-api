steps_for :well_ca_purchase do
  step 'there are the following products:' do |table|
    @products = table.hashes.map do |hash|
      double(
        source_url: hash['Source URL'],
        quantity: hash['Quantity'].to_i,
        sale_price_cents: hash['Sale price cents'].to_i,
        mark_as_out_of_stock!: true
      )
    end
  end

  step 'I am registered user' do
    user = double(
      email: 'john-doe-dae5@orders.shopbeam.com',
      password: '820af74d2d82'
    )

    @bot.instance_variable_set(:@proxy_user, user)
  end

  step 'I go to landing page' do
    @browser.goto Checkout::WellCa::Bot::BASE_URL
  end

  step 'I sign in' do
    @bot.send(:sign_in)
  end

  step 'I empty cart' do
    @bot.send(:empty_cart)
  end

  step 'I remove alternate addresses' do
    @bot.send(:delete_alternate_addresses)
  end

  step 'I remove samples' do
    @bot.send(:remove_samples, @products)

    items_in_cart = @browser.elements(class: 'shopping_cart_product_container')
    expect(items_in_cart.count).to eq(@products.count)
  end

  step 'I go to checkout page' do
    @browser.goto Checkout::WellCa::Bot::CHECKOUT_URL
  end

  step 'I skip recommendations' do
    @bot.send(:skip_recommendations)
  end

  step 'I skip samples' do
    @bot.send(:skip_samples)
  end

  step 'I fill shipping address' do
    @bot.send(:fill_shipping_address)
  end

  step 'I fill billing info' do
    @bot.send(:fill_billing_info)
  end

  step 'I should see confirm button' do
    expect(@browser.button(text: /confirm/i)).to be_present
  end
end
