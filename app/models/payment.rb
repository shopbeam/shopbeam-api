class Payment < ActiveRecord::Base
  self.table_name = 'Payment'
  self.inheritance_column = nil

  alias_attribute :expiration_month, :expirationMonth
  alias_attribute :expiration_year, :expirationYear

  def number
    Encryptor.decrypt(read_attribute(:number), read_attribute(:numberSalt))
  end

  def brand
    case number
    when /^4[0-9]{12}(?:[0-9]{3})?$/           then :visa
    when /^3[47][0-9]{13}$/                    then :amex
    when /^5[1-5][0-9]{14}$/                   then :master_card
    when /^6(?:011|5[0-9]{2})[0-9]{12}$/       then :discover
    when /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/    then :diners_club
    when /^(?:2131|1800|35[0-9]{3})[0-9]{11}$/ then :jcb
    end
  end

  private

  attr_writer :number
end
