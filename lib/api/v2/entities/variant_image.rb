module API
  module V2
    module Entities
      class VariantImage < Grape::Entity
        expose :id
        expose :source_url, as: :url
      end
    end
  end
end
