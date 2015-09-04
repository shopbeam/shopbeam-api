require 'rails_helper'

describe ShippingAddress do
  it { expect(subject.addressType).to eq(1) }
  it { is_expected.to delegate_method(:first_name).to(:user) }
  it { is_expected.to delegate_method(:last_name).to(:user) }
  it_behaves_like '#phone_number'
end
