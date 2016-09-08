class Brand < ActiveRecord::Base
  self.table_name = 'Brand'

  has_many :products, foreign_key: 'BrandId'
  belongs_to :partner, foreign_key: 'PartnerId'

  alias_attribute :partner_id, :PartnerId
end
