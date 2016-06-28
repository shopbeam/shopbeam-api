module API
  module V2
    class Orders
      module Validations
        class ValidatePrices < Grape::Validations::Base
          def validate_param!(key, params)
            params[key].each do |item|
              variant = Variant.where(id: item[:variantId]).first
              unless variant
                validation_error!(key, 'variant not found')
              end
              if variant.sale_price_cents
                validation_error!(key, 'salePriceCents is outdated') if variant.sale_price_cents != item[:salePriceCents].to_i
              elsif variant.list_price_cents
                validation_error!(key, 'listPriceCents is outdated') if variant.list_price_cents != item[:listPriceCents].to_i
              else
                validation_error!(key, 'price validation failed')
              end
            end
          end

          def validation_error!(attr, message)
            fail Grape::Exceptions::Validation, params: [@scope.full_name(attr)], message: message
          end

        end
      end
    end
  end
end
