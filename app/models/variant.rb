class Variant < ActiveRecord::Base
  self.table_name = 'Variant'

  belongs_to :product, foreign_key: 'ProductId'
  has_many :images, -> { where(status: 1) }, class_name: 'VariantImage', foreign_key: 'VariantId'

  delegate :partner, to: :product
  delegate :commission_percent, to: :partner

  alias_attribute :source_url, :sourceUrl
  alias_attribute :list_price_cents, :listPriceCents
  alias_attribute :sale_price_cents, :salePriceCents
end
