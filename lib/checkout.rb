module Checkout
  class CheckoutError < StandardError
    attr_accessor :screenshot, :page_source

    def initialize(url, message)
      @url = url
      @message = message
    end

    def to_s
      "#{self.class.name.demodulize}: The following error(s) occurred on #{@url}: #{@message}"
    end
  end

  class VariantNotAvailableError < CheckoutError
    def initialize(url, item)
      super url, "Requested variant (color: #{item.color}, size: #{item.size}) not available."
    end
  end

  class ItemOutOfStockError < CheckoutError
    def initialize(url:, requested_qty:, actual_qty:)
      super url, "#{requested_qty} requested but #{actual_qty} available."
    end
  end

  class ItemPriceMismatchError < CheckoutError
    include ActionView::Helpers::NumberHelper

    def initialize(url:, requested_price_cents:, actual_price_cents:)
      super url, "#{number_to_currency(requested_price_cents / 100.0)} expected but #{number_to_currency(actual_price_cents / 100.0)} got."
    end
  end

  class PartnerNotSupportedError < CheckoutError; end
  class InvalidCredentialsError < CheckoutError; end
  class InvalidAccountError < CheckoutError; end
  class InvalidAddressError < CheckoutError; end
  class InvalidShippingInfoError < CheckoutError; end
  class InvalidBillingInfoError < CheckoutError; end
  class ConfirmationError < CheckoutError; end
  class InvalidOrderNumberError < CheckoutError; end

  class MailError < StandardError; end

  class InvalidMailError < MailError
    MATCHED_LINES = Regexp.new <<-MATCHED.squish!
      <li class="del"><del>.*?match.*?match.*?</del></li>\\s*
      (<li class="del"><del>.*?</del></li>\\s*)*
      (<li class="ins"><ins>.*?</ins></li>\\s*)*
      (<li class="unchanged">.*?</li>\\s*)*
    MATCHED

    UNCHANGED_LINES = Regexp.new <<-UNCHANGED.squish!
      <li class="diff-block-info">.*?</li>\\s*
      (<li class="unchanged">.*?</li>\\s*)*
      (?=(<li class="diff-block-info">|</ul>))
    UNCHANGED

    attr_reader :diff

    def initialize(template, content)
      @diff = Diffy::Diff.new(template, content, context: 1, include_diff_info: true, ).to_s(:html)
      strip_diff!
    end

    private

    def strip_diff!
      stripped_diff = diff.gsub(MATCHED_LINES, '').gsub(UNCHANGED_LINES, '')

      diff.replace(stripped_diff) if stripped_diff =~ /<li class="diff-block-info">/
    end
  end

  class MailThemeNotFoundError < MailError
    attr_reader :number

    def initialize(number)
      @number = number
    end
  end

  class MailTemplateNotFoundError < MailError
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
  end

  class UnknownMailError < MailError; end
end
