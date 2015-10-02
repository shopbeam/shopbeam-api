require 'rails_helper'

describe CheckoutJob do
  subject(:perform) { described_class.new.perform(1) }

  it { expect(described_class).to be_retryable 2 }
  it { expect(described_class).to save_backtrace 5 }

  it 'subscribes checkout notifier as event listener' do
    expect_any_instance_of(Checkout::Shopper)
      .to receive(:subscribe).with(instance_of(Checkout::Notifier))
      .and_return(double(call: true))
    perform
  end

  it 'calls checkout shopper with the target order ID' do
    expect_any_instance_of(Checkout::Shopper)
      .to receive(:call).with(1)
    perform
  end
end
