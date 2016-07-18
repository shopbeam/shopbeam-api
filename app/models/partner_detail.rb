class PartnerDetail < ActiveRecord::Base
  # TODO: extract entity from the model
  include API::V2::Entities::PartnerDetail

  self.table_name = 'PartnerDetail'

  belongs_to :partner, foreign_key: :PartnerId
  has_many :item_count_shipping_costs, foreign_key: :PartnerDetailId

  scope :active, -> { where(status: 1) }
end
