class Payment < ActiveRecord::Base
  self.table_name = 'Payment'
  self.inheritance_column = nil

  alias_attribute :expiration_month, :expirationMonth
  alias_attribute :expiration_year, :expirationYear

  def number
    Encryptor.decrypt(read_attribute(:number), read_attribute(:numberSalt))
  end
end
