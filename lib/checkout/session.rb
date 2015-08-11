module Checkout
  class Session
    def initialize(user)
      @user = user
    end

    def commit(item)
      @item = item
      partner.purchase
    end

    def new_user?
      # TODO: implement proxy user here
      false
    end

    def user_data
      {
        email: 'bryan@shopbeam.com',
        password: 'badpassword'
      }
    end

    def product_url
      item.variant_source_url
    end

    def product_quantity
      item.quantity
    end

    private

    attr_reader :user, :item

    def partner
      Partners.lookup(product_url).new(self)
    end
  end
end
