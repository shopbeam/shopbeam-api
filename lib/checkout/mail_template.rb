module Checkout
  class MailTemplate < OpenStruct
    DEFAULT_THEME = 'default'

    include MailView::Helpers

    def initialize(proxy_user, validator, options)
      super(options)

      self.proxy_user = proxy_user
      @validator = validator
    end

    def render
      ERB.new(template).result(binding)
    end

    private

    attr_reader :validator

    def template
      filename = validator.to_s.underscore.sub('validators', "templates/#{theme}")
      filename = "app/views/#{filename}.html.erb"

      raise MailTemplateNotFoundError.new(filename) unless File.exist?(filename)

      File.read(filename)
    end

    def theme
      # Check whether order reference number (order_id) was initialized via options
      return DEFAULT_THEME unless respond_to?(:order_id)

      order =
        proxy_user
          .orders.joins(:references)
          .find_by(order_references: { partner_type: proxy_user.partner_type, number: order_id })

      raise MailThemeNotFoundError.new(order_id) unless order

      order.theme.underscore
    end
  end
end
