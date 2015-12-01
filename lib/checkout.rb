module Checkout
  class OrderError < StandardError
    attr_accessor :screenshot, :page_source

    def initialize(url, message)
      @url = url
      @message = message
    end

    def to_s
      "#{self.class.name.demodulize}: The following error(s) occurred on #{@url}: #{@message}"
    end
  end

  class VariantNotAvailableError < OrderError
    def initialize(url, item)
      super url, "Requested variant (color: #{item.color}, size: #{item.size}) not available."
    end
  end

  class ItemOutOfStockError < OrderError
    def initialize(url:, requested_qty:, actual_qty:)
      super url, "#{requested_qty} requested but #{actual_qty} available."
    end
  end

  class ItemPriceMismatchError < OrderError
    include ActionView::Helpers::NumberHelper

    def initialize(url:, requested_price_cents:, actual_price_cents:)
      super url, "#{number_to_currency(requested_price_cents / 100.0)} expected but #{number_to_currency(actual_price_cents / 100.0)} got."
    end
  end

  class PartnerNotSupportedError < OrderError; end
  class InvalidAccountError < OrderError; end
  class InvalidAddressError < OrderError; end
  class InvalidShippingInfoError < OrderError; end
  class InvalidBillingInfoError < OrderError; end
  class ConfirmationError < OrderError; end
  class InvalidOrderNumberError < OrderError; end

  class UnknownMailError < StandardError; end

  class InvalidMailError < StandardError
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

  class MailTemplateNotFoundError < StandardError
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end
  end
end
