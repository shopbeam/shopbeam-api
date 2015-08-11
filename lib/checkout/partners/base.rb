module Checkout
  module Partners
    class Base
      def initialize(session)
        @session = session
      end

      def purchase
        raise NotImplementedError, 'Subclasses must implement a purchase method.'
      end

      protected

      attr_reader :session

      def browser
        @browser ||= Checkout::Browser.new
      end
    end
  end
end
