module API
  module V2
    class PartnerDetails < Grape::API
      desc 'retrive shipment details for partners'
      params do
        optional :partner,  type: Array, coerce_with: Params::IntegerArray.method(:parse)
        optional :state,    type: Array, coerce_with: Params::StringArray.method(:parse)
      end

      resources :partnerdetails do
        get '/' do
          query = PartnerDetail.joins(:partner, :item_count_shipping_cost)
          handle_param(:partner)  { |ids| query.where!(PartnerId: ids) }
          handle_param(:state)    { |ids| query.where!(state: ids) }
          present query.all, with: API::V2::Entities::PartnerDetail::Entity
        end
      end
    end
  end
end
