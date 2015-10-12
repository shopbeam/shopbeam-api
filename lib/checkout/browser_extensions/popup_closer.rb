module Checkout
  module BrowserExtensions
    module PopupCloser
      def close_popup
        elements(xpath: PopupFinder.xpath).each do |popup|
          if popup.present?
            popup.click
            popup.wait_while_present
          end
        end
      end
    end

    module PopupFinder
      class << self
        SELECTORS = [
          ['id', 'monetate_lightbox'],
          ['class', 'ui-dialog-titlebar-close']
        ]

        def xpath
          @xpath ||= begin
            nodes = SELECTORS.map { |attribute, value| "contains(@#{attribute}, '#{value}')" }
            "//*[#{nodes.join(' or ')}]"
          end
        end
      end
    end
  end
end
