class Address < ActiveRecord::Base
  self.table_name = 'Address'
  self.inheritance_column = 'addressType'

  alias_attribute :phone_number, :phoneNumber
  alias_attribute :address_type, :addressType
  alias_attribute :user_id, :UserId

  def self.find_sti_class(type_name)
    self
  end
end
