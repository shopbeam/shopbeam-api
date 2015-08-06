require 'rails_helper'

describe CheckoutJob do
  let(:order) { create(:order) }

  subject(:job) { described_class.perform_later(order.id) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'calls checkout submitter' do
    expect(Checkout::Submitter)
      .to receive(:call).with(order, instance_of(Checkout::Notifier))
    perform_enqueued_jobs { job }
  end
end
