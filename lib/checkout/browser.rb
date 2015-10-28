module Checkout
  class Browser < DelegateClass(Watir::Browser)
    include ::Checkout::BrowserExtensions

    NET_TIMEOUT = 3 * 60
    WAIT_TIMEOUT = 60

    def initialize(driver: :chrome, headless: { display: Headless::DEFAULT_DISPLAY_NUMBER })
      client = Selenium::WebDriver::Remote::Http::Default.new

      client.timeout = NET_TIMEOUT
      Watir.default_timeout = WAIT_TIMEOUT

      if headless
        display = headless[:display] % Headless::MAX_DISPLAY_NUMBER
        @headless = Headless.new(display: display)
        @headless.start
      end

      super Watir::Browser.new(driver, http_client: client)
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
