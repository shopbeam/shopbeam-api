class ItemCountShippingCost < ActiveRecord::Base
  self.table_name = 'ItemCountShippingCost'

  belongs_to :partner_detail, foreign_key: :PartnerDetailId

  alias_attribute :shipping_price, :shippingPrice
  alias_attribute :item_count, :itemCount

  scope :active, -> { where(status: 1) }
end
