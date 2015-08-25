require 'rails_helper'

describe Payment do
  describe '#expiration_month' do
    it 'is an alias of #expirationMonth' do
      payment = described_class.new(expirationMonth: 6)

      expect(payment.expiration_month).to eq(6)
    end
  end

  describe '#expiration_year' do
    it 'is an alias of #expirationYear' do
      payment = described_class.new(expirationYear: 2020)

      expect(payment.expiration_year).to eq(2020)
    end
  end

  describe '#number' do
    it 'returns decrypted value' do
      encrypted_number = Encryptor.encrypt('1234567890')

      subject.send(:write_attribute, :number, encrypted_number[:value])
      subject.send(:write_attribute, :numberSalt, encrypted_number[:salt])

      expect(subject.number).to eq('1234567890')
    end
  end
end
