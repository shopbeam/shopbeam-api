class Address < ActiveRecord::Base
  self.table_name = 'Address'
  self.inheritance_column = 'addressType'

  def self.find_sti_class(type_name)
    self
  end
end
