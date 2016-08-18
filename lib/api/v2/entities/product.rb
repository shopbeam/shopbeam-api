module API
  module V2
    module Entities
      class Product < Grape::Entity
        expose :id
        expose :name
        expose :sku
        expose :description
        expose :salePercent
        expose :createdAt
        expose :colorSubstitute

        expose :minListPrice do |instance|
          # Do not use ActiveRecord::Calculations#minimum, it will cause extra query
          instance.variants.map(&:listPriceCents).min
        end

        expose :maxListPrice do |instance|
          # Do not use ActiveRecord::Calculations#maximum, it will cause extra query
          instance.variants.map(&:listPriceCents).max
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
