require 'rails_helper'

describe Order do
  it { is_expected.to have_many(:order_items).autosave(true) }

  %i(first_name last_name address1 address2 city state zip).each do |method|
    it { is_expected.to delegate_method(method).to(:shipping_address).with_prefix(:shipping) }
  end

  %i(first_name last_name address1 address2 city state zip).each do |method|
    it { is_expected.to delegate_method(method).to(:billing_address).with_prefix(:billing) }
  end

  %i(name number cvv expiration_month expiration_year).each do |method|
    it { is_expected.to delegate_method(method).to(:payment).with_prefix(:cc) }
  end

  describe '#status' do
    subject { described_class.new(status: code).status }

    context 'for code 9' do
      let(:code) { 9 }

      it { is_expected.to eq('pending') }
    end

    context 'for code 11' do
      let(:code) { 11 }

      it { is_expected.to eq('completed') }
    end

    context 'for code 8' do
      let(:code) { 8 }

      it { is_expected.to eq('aborted') }
    end
  end

  describe '.uncompleted' do
    let(:pending_order) { create(:order, status: 'pending') }
    let(:aborted_order) { create(:order, status: 'aborted') }
    let(:completed_order) { create(:order, status: 'completed') }

    subject { described_class.uncompleted }

    it { is_expected.to include(pending_order) }
    it { is_expected.to include(aborted_order) }
    it { is_expected.not_to include(completed_order) }
  end

  describe 'events' do
    let(:order_item) { build(:order_item) }
    let(:order) { create(:order, status: 'pending', order_items: [order_item]) }

    describe '#process!' do
      it {
        expect(order_item).to receive(:process)
        expect { order.process! }.not_to change(order, :status)
      }
    end

    describe '#complete!' do
      it {
        expect(order_item).to receive(:complete)
        expect { order.complete! }.to change(order, :status).to('completed')
      }
    end

    describe '#terminate!' do
      it {
        expect(order_item).to receive(:terminate)
        expect { order.terminate! }.to change(order, :status).to('aborted')
      }
    end

    describe '#abort!' do
      it {
        expect(order_item).to receive(:abort)
        expect { order.abort! }.to change(order, :status).to('aborted')
      }
    end
  end
end
