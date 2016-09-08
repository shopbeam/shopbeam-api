module API
  module V2
    module Entities
      class Consumer < Grape::Entity
        expose :id, :email, :created_at, :updated_at
      end
    end
  end
end
