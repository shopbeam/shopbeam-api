module Checkout
  module BrowserExtensions
    extend ActiveSupport::Concern

    included do
      include PopupCloser::Helpers
    end
  end
end
