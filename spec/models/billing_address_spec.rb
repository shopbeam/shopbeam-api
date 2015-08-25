require 'rails_helper'

describe BillingAddress do
  it { expect(subject.addressType).to eq(2) }
  it_behaves_like 'delegates methods to user', %i(first_name last_name)
end
