module Checkout
  class MailTemplate < OpenStruct
    include ActionView::Helpers
    include Rails.application.routes.url_helpers

    def self.default_url_options
      ActionMailer::Base.default_url_options
    end

    def initialize(proxy_user, validator, options)
      super(options)

      self.proxy_user = proxy_user
      @validator = validator
    end

    def html
      render :html
    end

    def text
      render :text
    end

    private

    attr_reader :validator

    def render(format)
      ERB.new(template(format)).result(binding)
    end

    def template(format)
      filename = validator.to_s.underscore.sub('validators', 'templates')
      File.read("app/views/#{filename}.#{format}.erb")
    end
  end
end
