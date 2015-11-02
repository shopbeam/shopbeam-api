module Checkout
  module BrowserExtensions
    module PopupCloser
      SELECTORS = [
        ['id', 'monetate_lightbox'],
        ['class', 'ui-dialog-titlebar-close']
      ]

      extend self

      module Helpers
        def close_popup
          elements(xpath: PopupCloser.xpath).each do |popup|
            if popup.present?
              popup.click
              popup.wait_while_present
            end
          end
        end
      end
      
      def xpath
        @xpath ||= begin
          nodes = SELECTORS.map { |attribute, value| "contains(@#{attribute}, '#{value}')" }
          "//*[#{nodes.join(' or ')}]"
        end
      end
    end
  end
end
