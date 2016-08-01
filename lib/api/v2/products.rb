module API
  module V2
    class Products < Grape::API
      resource :products do
        desc 'Retrieve products'
        params do
          optional :id,        type: Array[Integer], coerce_with: Params::IntegerList
          optional :partner,   type: Array[Integer], coerce_with: Params::IntegerList
          optional :brand,     type: Array[Integer], coerce_with: Params::IntegerList
          optional :category,  type: Array[Integer], coerce_with: Params::IntegerList
          optional :minprice,  type: Integer # TODO: implement custom validation: greater_than_or_equal_to: 0
          optional :maxprice,  type: Integer # TODO: implement custom validation: greater_than_or_equal_to: 0
          optional :sale,      type: Integer, values: 1..99
          optional :q,         type: String
          optional :sortby,    type: Symbol, values: [:recent, :lowtohigh, :hightolow, :relevance], default: :recent
          optional :limit,     type: Integer, values: 1..100, default: 20
          optional :offset,    type: Integer, default: 0 # TODO: implement custom validation: greater_than_or_equal_to: 0
        end
        get do
          products = ProductQuery.call do |query|
                       with_param(:id)       { |param| query.by_variant_id!(param) }
                       with_param(:partner)  { |param| query.by_partner_id!(param) }
                       with_param(:brand)    { |param| query.by_brand_id!(param) }
                       with_param(:category) { |param| query.by_category_id!(param) }
                       with_param(:minprice) { |param| query.by_min_price!(param) }
                       with_param(:maxprice) { |param| query.by_max_price!(param) }
                       with_param(:sale)     { |param| query.by_sale_percent!(param) }
                       with_param(:q)        { |param| query.search!(param) }
                       with_param(:sortby)   { |param| query.sort_by!(param) }
                       with_param(:limit)    { |param| query.limit!(param) }
                       with_param(:offset)   { |param| query.offset!(param) }
                     end

          present products, with: API::V2::Entities::Product
        end
      end
    end
  end
end
