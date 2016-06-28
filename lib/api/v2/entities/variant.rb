module API
  module V2
    module Entities
      class Variant < Grape::Entity
        expose :id, :sku, :sourceUrl, :color, :colorFamily, :size
        expose :list_price_cents, as: :listPrice
        expose :sale_price_cents, as: :salePrice
        expose :images, using: API::V2::Entities::VariantImage
      end
    end
  end
end
