module Checkout
  module Partners
    class Base
      def initialize(session)
        @session = session
      end

      def purchase(items)
        raise NotImplementedError, 'Subclasses must implement a purchase(items) method.'
      end

      def new_user?
        proxy_user.new_record?
      end

      protected

      attr_reader :session

      def browser
        @browser ||= Checkout::Browser.new
      end

      def proxy_user
        @proxy_user ||= ProxyUser.find_or_initialize_by(user: session.user, provider_type: self.class)
      end
    end
  end
end
