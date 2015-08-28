module Checkout
  class Browser < DelegateClass(Watir::Browser)
    def initialize(driver: :chrome, headlessly: true)
      if headlessly
        @headless = Headless.new
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
  end
end
