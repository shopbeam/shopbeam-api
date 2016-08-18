module API
  module V2
    module Entities
      class Partner < Grape::Entity
        expose :id
        expose :name
        expose :commission
        expose :policyUrl
        expose :details, using: API::V2::Entities::PartnerDetail, as: :partnerDetails
      end
    end
  end
end
