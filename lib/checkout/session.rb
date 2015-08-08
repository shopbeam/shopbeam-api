module Checkout
  class Session
    def initialize(user)
      @user = user
    end

    def commit(item)
      @item = item
      provider.shop(self)
    end

    private

    attr_reader :user, :item

    def provider
      Providers.lookup(item.variant_source_url).new
    end
  end
end
