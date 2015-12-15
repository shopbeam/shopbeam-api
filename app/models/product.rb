class Product <  ActiveRecord::Base
  self.table_name = 'Product'
  has_many :variants, foreign_key: 'ProductId'
  belongs_to :brand, foreign_key: 'BrandId'
end
