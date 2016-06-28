class PartnerDetail < ActiveRecord::Base
  self.table_name = 'PartnerDetail'

  belongs_to :partner, foreign_key: :PartnerId
  has_many :shipping_items, -> { active }, foreign_key: :PartnerDetailId, class_name: 'ItemCountShippingCost'

  scope :active, -> { where(status: 1) }
end
