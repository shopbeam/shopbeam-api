class Variant < ActiveRecord::Base
  self.table_name = 'Variant'

  belongs_to :product, foreign_key: 'ProductId'
  has_many :images, -> { where(status: 1) }, class_name: 'VariantImage', foreign_key: 'VariantId'

  alias_attribute :source_url, :sourceUrl
  alias_attribute :list_price_cents, :listPriceCents
  alias_attribute :sale_price_cents, :salePriceCents

  class Entity < Grape::Entity
    expose :id, :sku, :sourceUrl, :color, :colorFamily, :size

    expose :listPrice do |v|
      v.list_price_cents
    end

    expose :salePrice do |v|
      v.sale_price_cents
    end

    expose :images, using: VariantImage::Entity
  end
end
