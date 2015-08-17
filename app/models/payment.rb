class Payment < ActiveRecord::Base
  self.table_name = 'Payment'
  self.inheritance_column = nil

  def number
    Encryptor.decrypt(read_attribute(:number), read_attribute(:numberSalt))
  end
end
