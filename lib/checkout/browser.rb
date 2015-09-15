module Checkout
  class Browser < DelegateClass(Watir::Browser)
    def initialize(driver: :chrome, headless: { display: Headless::DEFAULT_DISPLAY_NUMBER })
      if headless
        display = headless[:display] % Headless::MAX_DISPLAY_NUMBER
        @headless = Headless.new(display: display)
        @headless.start
      end

      super Watir::Browser.new(driver)
    end

    def open
      yield
    ensure
      close
    end

    def close
      super
      @headless.destroy if @headless
    end

    def on_page?(page_url)
      Regexp.new(Regexp.quote(page_url)) =~ url
    end

    def wait_for_ajax
      yield if block_given?
      Watir::Wait.until { execute_script('return jQuery.active') == 0 }
    end
  end
end
