module Checkout
  module BrowserExtensions
    extend ActiveSupport::Concern

    included do
      include PopupCloser
    end
  end
end
