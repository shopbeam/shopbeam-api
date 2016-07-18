class PartnerDetail < ActiveRecord::Base
  self.table_name = 'PartnerDetail'

  belongs_to :partner, foreign_key: :PartnerId

  with_options foreign_key: :PartnerDetailId, class_name: 'ItemCountShippingCost' do
    has_many :shipping_items
    has_many :active_shipping_items, -> { active }
  end

  scope :active, -> { where(status: 1) }
end
