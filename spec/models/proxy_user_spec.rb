require 'rails_helper'

describe ProxyUser do
  it { is_expected.to delegate_method(:first_name).to(:user) }
  it { is_expected.to delegate_method(:last_name).to(:user) }
  it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }

  describe 'validations' do
    subject { create(:proxy_user) }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:partner_type) }
    it { is_expected.to validate_presence_of(:partner_type) }
  end

  describe 'default values' do
    subject { described_class.new(user: build(:user, first_name: 'John', last_name: 'Smith')) }

    it { expect(subject.email).to match(/\Ajohn-smith-\h{4}@orders\.shopbeam\.com\z/) }
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
