When(/^I add products to cart$/) do
  begin
    @products.each do |product|
      @bot.send(:add_to_cart, product)
    end
  rescue Checkout::ItemOutOfStockError, Checkout::ItemPriceMismatchError => exception
    puts "[WARNING] #{exception.message}"
    Cucumber.wants_to_quit = true
  end
end
