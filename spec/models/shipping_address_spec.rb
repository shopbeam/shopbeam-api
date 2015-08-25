require 'rails_helper'

describe ShippingAddress do
  it { expect(subject.addressType).to eq(1) }
  it_behaves_like 'delegates methods to user', %i(first_name last_name)
end
