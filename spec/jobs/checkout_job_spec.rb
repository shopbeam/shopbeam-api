require 'rails_helper'

describe CheckoutJob do
  it { expect(described_class).to be_retryable(2) }
  it { expect(described_class).to save_backtrace(5) }

  it 'subscribes checkout notifier as event listener' do
    order_id = 1

    expect_any_instance_of(Checkout::Shopper)
      .to receive(:subscribe).with(instance_of(Checkout::Notifier))
      .and_return(double(call: true))

    subject.perform(order_id)
  end

  it 'calls checkout shopper with the target order ID' do
    order_id = 1

    expect_any_instance_of(Checkout::Shopper)
      .to receive(:call).with(order_id)

    subject.perform(order_id)
  end
end
