module API
  module V2
    module Entities
      module Partner
        class Entity < Grape::Entity
          expose :id, :name
        end
      end
    end
  end
end
