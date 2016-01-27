class ProductCategory < ActiveRecord::Base
  self.table_name = 'ProductCategory'

  belongs_to :product, foreign_key: :ProductId
  belongs_to :category, foreign_key: :CategoryId

  alias_attribute :category_id, :CategoryId
end
