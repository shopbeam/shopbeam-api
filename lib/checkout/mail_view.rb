module Checkout
  module MailView
    module Helpers
      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers
        include Rails.application.routes.url_helpers

        # Override ActionDispatch's default_url_options here, since
        # included block is evaluated after ClassMethods definition
        def self.default_url_options
          ActionMailer::Base.default_url_options
        end
      end

      def config
        # Proxy application configuration
        Config
      end
    end

    module Config
      def self.asset_host
        ActionMailer::Base.config.asset_host
      end
    end
  end
end
