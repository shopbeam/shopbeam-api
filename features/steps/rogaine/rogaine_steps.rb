def price_should_be_visible
  sleep 5 #wait for animations
  price_visible = @browser.iframe(id: 'shopbeam-lightbox').div(class: "prices").visible?
  expect(price_visible).to be_truthy
end

def lightbox_should_be_closed
  sleep 5 #wait for animations
  lightbox_visible = @browser.iframe(id: 'shopbeam-lightbox').visible?
  expect(lightbox_visible).to be_falsy
end

When(/^I go to manual testing page$/) do
  @browser = Checkout::Browser.new
  @browser.goto 'https://staging.shopbeam.com/manual-testing/rogaine-example.html'
  sleep 5 # wait page and iframes to load
end

Then(/^all image widgets should be clickable and not out of stock$/) do
  @browser.iframes[0..3].each do |image_widget|
    image_widget.click
    price_should_be_visible
    @browser.iframe(id: 'shopbeam-lightbox').buttons[4].click
    lightbox_should_be_closed
  end
end

Then(/^all text widgets should be clickable and not out of stock$/) do
  @browser.links.each do |text_widget|
    text_widget.click
    price_should_be_visible
    @browser.iframe(id: 'shopbeam-lightbox').buttons[4].click
    lightbox_should_be_closed
  end
end
