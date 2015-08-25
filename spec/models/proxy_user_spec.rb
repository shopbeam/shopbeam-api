require 'rails_helper'

describe ProxyUser do
  it_behaves_like 'delegates methods to user', %i(first_name last_name)

  describe 'validations' do
    subject { create(:proxy_user) }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:provider_type) }
    it { is_expected.to validate_presence_of(:provider_type) }
  end

  describe 'default values' do
    subject { described_class.new(user: build(:user, first_name: 'John', last_name: 'Smith')) }

    it { expect(subject.email).to match(/\Ajohn-smith-\h{4}@checkout\.shopbeam\.com\z/) }
    it { expect(subject.password).to match(/\A\h{12}\z/) }
  end

  describe '#password' do
    it 'returns decrypted value' do
      encrypted_password = Encryptor.encrypt('a1b2c3d4')

      subject.send(:write_attribute, :password, encrypted_password[:value])
      subject.send(:write_attribute, :password_salt, encrypted_password[:salt])

      expect(subject.password).to eq('a1b2c3d4')
    end
  end
end
