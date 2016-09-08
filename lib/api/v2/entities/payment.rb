module API
  module V2
    module Entities
      class Payment < Grape::Entity
        expose :type

        expose :number do |instance|
          instance.read_attribute(:number)
        end

        expose :expirationMonth do |instance|
          instance.read_attribute(:expirationMonth)
        end

        expose :expirationYear do |instance|
          instance.read_attribute(:expirationYear)
        end

        expose :name do |instance|
          instance.read_attribute(:name)
        end

        expose :cvv do |instance|
          instance.read_attribute(:cvv)
        end

        expose :salt
      end
    end
  end
end
