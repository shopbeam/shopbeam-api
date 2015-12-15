class Variant < ActiveRecord::Base
  self.table_name = 'Variant'

  has_many :images, foreign_key: 'VariantId', class_name: 'VariantImg'
  belongs_to :product, foreign_key: 'ProductId'

  alias_attribute :source_url, :sourceUrl
end
