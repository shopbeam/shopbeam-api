require 'rails_helper'

describe Encryptor do
  describe '.encrypt' do
    it 'returns encrypted data' do
      result = described_class.encrypt('foo')

      expect(result).to have_key(:value)
      expect(result).to have_key(:salt)
      expect(result[:value]).not_to eq('foo')
    end

    it 'encrypts with custom salt' do
      salt = SecureRandom.base64

      result = described_class.encrypt('foo', salt)

      expect(result[:salt]).to eq(salt)
    end
  end

  describe '.decrypt' do
    it 'returns decrypted value' do
      value, salt = described_class.encrypt('foo').values_at(:value, :salt)

      expect(described_class.decrypt(value, salt)).to eq('foo')
    end
  end
end
