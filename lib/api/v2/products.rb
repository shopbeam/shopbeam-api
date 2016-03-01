module API
  module V2
    class Products < Grape::API
      desc 'retrive products'
      params do
        optional :id,       type: Array, coerce_with: Params::IntegerArray.method(:parse)
        optional :partner,  type: Array, coerce_with: Params::IntegerArray.method(:parse)
        optional :brand,    type: Array, coerce_with: Params::IntegerArray.method(:parse)
        optional :category, type: Array, coerce_with: Params::IntegerArray.method(:parse)
        optional :color,    type: Array, coerce_with: Params::StringArray.method(:parse)
        optional :size,     type: Array, coerce_with: Params::StringArray.method(:parse)
        optional :minprice, type: Integer
        optional :maxprice, type: Integer
        optional :limit,    type: Integer
      end
      resource :products do
        get '/' do
          query = Product.joins(:brand, :partner, :variants).includes(:variants, :categories)
          query.where!(Variant: {status: 1}, Partner: {status: 1}, status: 1).limit(100)
          handle_param(:limit)    { |lim| query.limit!(lim) }
          handle_param(:id)       { |ids| query.where!(Variant:  {id: ids}) }
          handle_param(:limit)    { |lim| query.limit(lim) }
          handle_param(:partner)  { |ids| query.where!(Partner:  {id: ids}) }
          handle_param(:brand)    { |ids| query.where!(Brand:    {id: ids}) }
          handle_param(:category) { |ids| query.where!(Category: {id: ids}) }
          handle_param(:color) do |c|
            colors = c.join(',')
            query.where!('"Variant"."color" ~~* ANY(?) OR ( ? && ("Variant"."colorFamily") )', "{#{colors}}", "{#{colors}}")
          end
          handle_param(:size) do |s|
            sizes = s.join(',')
            query.where!('"Variant"."size" ILIKE ANY(?)', "{#{sizes}}")
          end
          handle_param(:minprice) do |v|
            query.where!('COALESCE(NULLIF("Variant"."salePriceCents", 0), "Variant"."listPriceCents") >= ?', v)
          end
          handle_param(:maxprice) do |v|
            query.where!('COALESCE(NULLIF("Variant"."salePriceCents", 0), "Variant"."listPriceCents") <= ?', v)
          end
          present query.all
        end
      end
    end
  end
end
