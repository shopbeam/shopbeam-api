class Category < ActiveRecord::Base
  self.table_name = 'Category'

  has_many :product_categories, -> { where(status: 1) }, foreign_key: :CategoryId
end
