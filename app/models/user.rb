class User < ActiveRecord::Base
  self.table_name = 'User'

  alias_attribute :first_name, :firstName
  alias_attribute :last_name, :lastName
end
