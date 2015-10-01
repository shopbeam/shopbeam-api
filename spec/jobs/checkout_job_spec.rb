require 'rails_helper'

describe CheckoutJob do
  subject(:job) { described_class.perform_async(1) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'subscribes checkout notifier as event listener' do
    expect_any_instance_of(Checkout::Shopper)
      .to receive(:subscribe).with(instance_of(Checkout::Notifier))
      .and_return(double(call: true))
    perform_enqueued_jobs { job }
  end

  it 'calls checkout shopper with the target order ID' do
    expect_any_instance_of(Checkout::Shopper)
      .to receive(:call).with(1)
    perform_enqueued_jobs { job }
  end
end
