class Brand < ActiveRecord::Base
  self.table_name = 'Brand'
  has_many :products, foreign_key: 'BrandId'
end
