steps_for :rogaine do
  def price_should_be_visible
    #TODO: handle this in more intelegent way - like firing event from widget
    sleep 2 # wait for animations
    price = @browser.iframe(id: 'shopbeam-lightbox').div(class: 'prices')
    expect(price).to be_visible
  end

  def lightbox_should_be_closed
    sleep 2 # wait for animations
    lightbox = @browser.iframe(id: 'shopbeam-lightbox')
    expect(lightbox).not_to be_visible
  end

  def handle_first_time_popup
    sleep 1 #wait for animations
    popup = @browser.iframe(id: 'shopbeam-lightbox').button(class: 'dismiss')
    popup.click if popup.visible?
  end

  step 'I go to demo page with :url' do |url|
    ap url
    @browser = Checkout::Browser.new
    @browser.goto url
    sleep 3 # wait page and iframes to load
  end

  step 'all image widgets should be clickable and not out of stock' do
    @browser.iframes.each do |image_widget|
      if image_widget.id.include?('shopbeam-widget-image')
        image_widget.click
        handle_first_time_popup
        price_should_be_visible
        @browser.iframe(id: 'shopbeam-lightbox').buttons[4].click
        lightbox_should_be_closed
      elsif image_widget.id.include?('shopbeam-in-frame-widget-image')
        price = image_widget.div(class: 'prices')
        price.click
        expect(price).to be_visible
      else
        next
      end
    end
  end

  step 'all text widgets should be clickable and not out of stock' do
    @browser.elements(:css, 'a[data-shopbeam-url]').each do |text_widget|
      if text_widget.images.any?
        text_widget.images.first.click
      else
        text_widget.click
      end
      handle_first_time_popup
      price_should_be_visible
      @browser.iframe(id: 'shopbeam-lightbox').buttons[4].click
      lightbox_should_be_closed
    end
  end
end
