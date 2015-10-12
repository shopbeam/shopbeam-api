module Checkout
  class Browser < DelegateClass(Watir::Browser)
    include ::Checkout::BrowserExtensions

    TIMEOUT = 60 # seconds

    def initialize(driver: :chrome, headless: { display: Headless::DEFAULT_DISPLAY_NUMBER })
      if headless
        display = headless[:display] % Headless::MAX_DISPLAY_NUMBER
        @headless = Headless.new(display: display)
        @headless.start
      end

      super Watir::Browser.new(driver)

      Watir.default_timeout = TIMEOUT
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

    def goto(*)
      super
      close_popup
    end

    def click_on(el)
      close_popup
      wait_for_ajax { el.click }
      close_popup
    end

    def on_page?(page_url)
      Regexp.new(Regexp.escape(page_url)) =~ url
    end

    def wait_for_ajax
      yield if block_given?
      Watir::Wait.until { execute_script('return jQuery.active') == 0 }
    end
  end
end
