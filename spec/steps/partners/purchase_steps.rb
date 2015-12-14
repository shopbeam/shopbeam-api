steps_for :purchase do
  step 'I add products to cart' do
    begin
      @products.each do |product|
        @bot.send(:add_to_cart, product)
      end
    rescue Checkout::ItemOutOfStockError,
           Checkout::ItemPriceMismatchError => exception
      fail "[WARNING] #{exception.message}"
    end
  end
end
