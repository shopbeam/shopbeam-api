module API
  module V2
    class PartnerDetails < Grape::API
      resource :partnerdetails do
        desc 'Retrieve partners'
        params do
          optional :partner, type: Array[Integer], coerce_with: Params::IntegerList
          optional :state,   type: Array[String], coerce_with: Params::StringList
        end
        get do
          partners = PartnerQuery.call do |query|
                       with_param(:partner) { |param| query.by_partner_id!(param) }
                       with_param(:state)   { |param| query.by_state!(param) }
                     end

          present partners, with: API::V2::Entities::Partner
        end
      end
    end
  end
end
