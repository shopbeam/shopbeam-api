require 'rails_helper'

describe CheckoutJob do
  let(:order) { create(:order) }
  let(:submitter) { instance_double('Checkout::Submitter').as_null_object }

  subject(:job) { described_class.perform_later(order.id) }

  before do
    expect(Checkout::Submitter).to receive(:new).with(order).and_return(submitter)
  end

  after do
    perform_enqueued_jobs { job }

    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'subscribes checkout notifier as a listener of submitter events' do
    expect(submitter).to receive(:subscribe).with(instance_of(Checkout::Notifier))
  end

  it 'calls checkout submitter service' do
    expect(submitter).to receive(:call)
  end
end
