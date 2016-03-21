class User < ActiveRecord::Base
  self.table_name = 'User'

  has_many :orders, class_name: 'Order', foreign_key: 'UserId'

  alias_attribute :first_name, :firstName
  alias_attribute :last_name, :lastName
  alias_attribute :api_key, :apiKey
end
