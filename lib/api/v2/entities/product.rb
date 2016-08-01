module API
  module V2
    module Entities
      class Product < Grape::Entity
        expose :id, :name, :sku, :description, :salePercent, :createdAt, :colorSubstitute

        expose :minListPrice do |product|
          product.variants.map(&:listPriceCents).min
        end

        expose :maxListPrice do |product|
          product.variants.map(&:listPriceCents).max
        end

        expose :min_price_cents, as: :minPrice
        expose :max_price_cents, as: :maxPrice
        expose :partner_id, as: :partnerId
        expose :partner_commission, as: :partnerCommission
        expose :partner_name, as: :partnerName
        expose :partner_linkshare_id, as: :partnerLinkshareId
        expose :brand_id, as: :brandId
        expose :brand_name, as: :brandName
        expose :categories, using: Category::Entity
        expose :variants, using: Variant::Entity
      end
    end
  end
end
