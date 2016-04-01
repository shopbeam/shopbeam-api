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
        rescue StandardError => exception
          unless exception.kind_of?(OrderError)
            # Decorate standard error
            exception = OrderError.new(browser.url, exception.message)
          end

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

    def add_to_cart(item)
      browser.goto item.source_url
      yield
    rescue ItemOutOfStockError
      item.mark_as_out_of_stock!
      raise
    end

    def ensure_price_match(item, price_cents)
      if price_cents > item.price_cents
        raise ItemPriceMismatchError.new(
          url: item.source_url,
          requested_price_cents: item.price_cents,
          actual_price_cents: price_cents
        )
      end
    end

    def fill_address
      yield
    rescue Watir::Exception::NoValueFoundException => exception
      raise InvalidAddressError.new(browser.url, exception.message)
    end
  end
end
