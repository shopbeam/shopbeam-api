module API
  module V2
    module Entities
      class Partner < Grape::Entity
        expose :id, :name, :commission, :policyUrl
        expose :details, using: API::V2::Entities::PartnerDetail, as: :partnerDetails
      end
    end
  end
end
