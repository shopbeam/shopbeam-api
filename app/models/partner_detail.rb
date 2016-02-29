class PartnerDetail < ActiveRecord::Base
  include API::V2::Entities::PartnerDetail

  self.table_name = 'PartnerDetail'

  belongs_to :partner, foreign_key: :PartnerId
end
