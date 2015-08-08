class OrderItem < ActiveRecord::Base
  self.table_name = 'OrderItem'

  belongs_to :variant, foreign_key: 'VariantId'
  delegate :source_url, to: :variant, prefix: true
end
