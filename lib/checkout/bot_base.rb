module Checkout
  class BotBase
    def initialize(session)
      @session = session
    end

    def self.partner_type
      name.deconstantize.demodulize
    end

    def purchase!(items)
      browser.open do
        begin
          yield
        rescue OrderError => exception
          filename = "#{session.id}_#{Time.now.utc.strftime('%Y%m%d%H%M%S')}"
          screenshot = Rails.root.join('tmp', "#{filename}.png")
          page_source = Rails.root.join('tmp', "#{filename}.html")

          browser.screenshot.save screenshot
          File.open(page_source, 'w') { |f| f.write(browser.html) }

          exception.screenshot = screenshot.to_path
          exception.page_source = page_source.to_path

          raise exception
        end
      end
    end

    def new_user?
      proxy_user.new_record?
    end

    def partner_type
      self.class.partner_type
    end

    protected

    attr_reader :session

    def browser
      @browser ||= Checkout::Browser.new(headless: { display: session.id })
    end

    def proxy_user
      @proxy_user ||= ProxyUser.find_or_initialize_by(user: session.user, partner_type: partner_type)
    end

    def fill_address
      yield
    rescue Watir::Exception::NoValueFoundException => exception
      raise InvalidAddressError.new(browser.url, exception.message)
    end
  end
end
