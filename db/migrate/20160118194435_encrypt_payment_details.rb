class EncryptPaymentDetails < ActiveRecord::Migration
  ATTRIBUTES_TO_ENCRYPT = %i(expirationMonth expirationYear name cvv)

  def up
    result = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }

    PaymentTemp.find_each do |payment|
      ATTRIBUTES_TO_ENCRYPT.each do |attribute|
        value = payment.read_attribute(attribute).to_s
        next if value.empty?
        result[payment.id][attribute] = Encryptor.encrypt(value, payment.salt)[:value]
      end
    end

    PaymentTemp.update(result.keys, result.values)
  end

  def down
    result = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }

    PaymentTemp.find_each do |payment|
      ATTRIBUTES_TO_ENCRYPT.each do |attribute|
        value = payment.read_attribute(attribute).to_s
        next if value.empty?
        result[payment.id][attribute] = Encryptor.decrypt(value, payment.salt)
      end
    end

    PaymentTemp.update(result.keys, result.values)
  end

  private

  class PaymentTemp < ActiveRecord::Base
    self.table_name = 'Payment'
    self.inheritance_column = nil
  end
end
