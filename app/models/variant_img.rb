class VariantImg < ActiveRecord::Base
  self.table_name = 'VariantImg'

  alias_attribute :variant_id, :VariantId
  alias_attribute :source_url, :sourceUrl
  belongs_to :variant
end
