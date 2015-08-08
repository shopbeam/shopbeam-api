require 'rails_helper'

describe OrderItem do
  it { is_expected.to delegate_method(:source_url).to(:variant).with_prefix }
end
