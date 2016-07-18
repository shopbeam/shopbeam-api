module API
  module V2
    class PartnerDetails < Grape::API
      desc 'retrieve shipment details for partners'
      params do
        optional :partner, type: Array[Integer], coerce_with: Params::IntegerList
        optional :state,   type: Array[String], coerce_with: Params::StringList
      end

      resources :partnerdetails do
        get '/' do
          partner_details = PartnerDetailQuery.new(
                              partner_id: declared_params[:partner],
                              state: declared_params[:state]
                            ).by_partner

          present partner_details, with: API::V2::Entities::PartnerDetail::Entity
        end
      end
    end
  end
end
