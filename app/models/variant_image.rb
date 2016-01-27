class VariantImage < ActiveRecord::Base
  self.table_name = 'VariantImg'

  belongs_to :variant, foreign_key: :VariantId

  alias_attribute :source_url, :sourceUrl

  class Entity < Grape::Entity
    expose :id
    expose :url do |vi|
      vi.source_url
    end
  end
end
