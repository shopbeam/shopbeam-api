class Brand < ActiveRecord::Base
  self.table_name = 'Brand'

  alias_attribute :partner_id, :PartnerId

  has_many :products, foreign_key: 'BrandId'
  belongs_to :partner, foreign_key: 'PartnerId'
end
