module Checkout
  class Browser < DelegateClass(Watir::Browser)
    def initialize
      super Watir::Browser.new(:chrome)
    end

    def open
      yield
    ensure
      close
    end
  end
end
