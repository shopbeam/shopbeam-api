module Checkout
  class MailDispatcherBase
    def initialize(params)
      @params = params
    end

    def call
      raise NotImplementedError, 'Subclasses must implement a call method.'
    end

    protected

    attr_reader :params

    def delivery_options
      {
        to: proxy_user.user_email,
        subject: params[:subject],
        body_html: params[:'body-html'].html_safe,
        body_plain: params[:'body-plain']
      }
    end

    def proxy_user
      @proxy_user ||= ProxyUser.find_by_email(params[:recipient])
    end
  end
end
