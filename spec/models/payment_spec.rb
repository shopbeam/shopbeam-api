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

  describe '#brand' do
    shared_examples 'recognizes credit card as' do |brand, numbers|
      numbers.each do |number|
        it {
          expect_any_instance_of(described_class).to receive(:number).and_return(number)
          expect(subject.brand).to eq(brand)
        }
      end
    end

    it_behaves_like 'recognizes credit card as', :visa, %w(
      4111111111111111
      4012888888881881
      4222222222222
    )

    it_behaves_like 'recognizes credit card as', :amex, %w(
      378282246310005
      371449635398431
      378734493671000
    )

    it_behaves_like 'recognizes credit card as', :master_card, %w(
      5555555555554444
      5105105105105100
    )

    it_behaves_like 'recognizes credit card as', :discover, %w(
      6011111111111117
      6011000990139424
    )

    it_behaves_like 'recognizes credit card as', :diners_club, %w(
      30569309025904
      38520000023237
    )

    it_behaves_like 'recognizes credit card as', :jcb, %w(
      3530111333300000
      3566002020360505
    )
  end
end
