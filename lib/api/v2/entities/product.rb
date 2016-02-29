module API
  module V2
    module Entities
      module Product
        class Entity < Grape::Entity
          expose :id, :name, :description, :sku, :salePercent, :createdAt, :colorSubstitute

          expose :minListPrice do |product|
            product.variants.minimum(:listPriceCents)
          end

          expose :maxListPrice do |product|
            product.variants.maximum(:listPriceCents)
          end

          expose :minPrice do |product|
            product.min_price_cents
          end

          expose :maxPrice do |product|
            product.max_price_cents
          end

          expose :partnerId do |product|
            product.brand.partner_id
          end

          expose :partnerCommission do |product|
            product.brand.partner.commission
          end

          expose :partnerName do |product|
            product.brand.partner.name
          end

          expose :partnerLinkshareId do |product|
            product.brand.partner.linkshare_id
          end

          expose :brandId do |product|
            product.brand_id
          end

          expose :brandName do |product|
            product.brand.name
          end

          expose :categories, using: Category::Entity
          expose :variants, using: Variant::Entity
        end
      end
    end
  end
end
