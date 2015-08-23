require 'rails_helper'

describe CheckoutJob do
  let(:order) { create(:order) }

  subject(:job) { described_class.perform_later(order.id) }

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

  it 'calls checkout shopper for the current order' do
    expect_any_instance_of(Checkout::Shopper)
      .to receive(:call).with(order)
    perform_enqueued_jobs { job }
  end
end
