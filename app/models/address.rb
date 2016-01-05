class Address < ActiveRecord::Base
  self.table_name = 'Address'
  self.inheritance_column = 'addressType'

  alias_attribute :phone_number, :phoneNumber

  def self.find_sti_class(type_name)
    self
  end
end
