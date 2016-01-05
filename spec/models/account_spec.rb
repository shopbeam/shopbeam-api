require 'rails_helper'

describe Account do
  %i(phone_number country address1 address2 city state zip).each do |method|
    it { is_expected.to delegate_method(method).to(:address) }
  end

  describe '.inactive' do
    let(:pending_account) { create(:account, aasm_state: 'pending') }
    let(:aborted_account) { create(:account, aasm_state: 'aborted') }
    let(:active_account) { create(:account, aasm_state: 'active') }

    subject { described_class.inactive }

    it { is_expected.to include(pending_account) }
    it { is_expected.to include(aborted_account) }
    it { is_expected.not_to include(active_account) }
  end

  describe 'validations' do
    subject { build(:account) }

    %i(partner_type first_name last_name email).each do |field|
      it { is_expected.to validate_presence_of(field) }
    end

    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:partner_type) }
  end

  describe 'default values' do
    it { expect(subject.aasm_state).to eq('pending') }
  end

  describe 'events' do
    let(:account) { build(:account, aasm_state: 'pending') }

    describe '#process!' do
      it { expect { account.process! }.not_to change(account, :aasm_state) }
    end

    describe '#activate!' do
      it { expect { account.activate! }.to change(account, :aasm_state).to('active') }
    end

    describe '#abort!' do
      it { expect { account.abort! }.to change(account, :aasm_state).to('aborted') }
    end
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
