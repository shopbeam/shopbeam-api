module API
  module V2
    module Entities
      class Category < Grape::Entity
        expose :id, :name
      end
    end
  end
end
