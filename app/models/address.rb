class Address < ActiveRecord::Base
  self.table_name = 'Address'
  self.inheritance_column = 'addressType'

  belongs_to :user, foreign_key: 'UserId'
  delegate :first_name, :last_name, to: :user
  alias_attribute :phone_number, :phoneNumber

  def self.find_sti_class(type_name)
    self
  end
end
