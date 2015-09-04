require 'rails_helper'

describe OrderItem do
  %i(source_url color size).each do |method|
    it { is_expected.to delegate_method(method).to(:variant) }
  end

  describe '#sale_price_cents' do
    it 'is an alias of #salePriceCents' do
      payment = described_class.new(salePriceCents: 100)

      expect(payment.sale_price_cents).to eq(100)
    end
  end

  describe '#status' do
    subject { described_class.new(status: code).status }

    context 'for code 9' do
      let(:code) { 9 }

      it { is_expected.to eq('pending') }
    end

    context 'for code 12' do
      let(:code) { 12 }

      it { is_expected.to eq('processed') }
    end

    context 'for code 5' do
      let(:code) { 5 }

      it { is_expected.to eq('out_of_stock') }
    end

    context 'for code 13' do
      let(:code) { 13 }

      it { is_expected.to eq('unprocessed') }
    end

    context 'for code 14' do
      let(:code) { 14 }

      it { is_expected.to eq('aborted') }
    end
  end

  describe '#partner' do
    it 'calls partners lookup with source url' do
      order_item = described_class.new(variant: build(:variant, source_url: 'http://foo.com/'))

      expect(Checkout::Partners).to receive(:lookup).with('http://foo.com/').and_return('FooPartner')
      expect(order_item.partner).to eq('FooPartner')
    end
  end

  describe 'events' do
    let(:order_item) { create(:order_item, status: 'pending') }

    describe '#process' do
      it { expect { order_item.process }.not_to change(order_item, :status) }
    end

    describe '#complete' do
      it { expect { order_item.complete }.to change(order_item, :status).to('processed') }
    end

    describe '#mark_as_out_of_stock' do
      it { expect { order_item.mark_as_out_of_stock }.to change(order_item, :status).to('out_of_stock') }
    end

    describe '#terminate' do
      it { expect { order_item.terminate }.to change(order_item, :status).to('unprocessed') }
    end

    describe '#abort' do
      it { expect { order_item.abort }.to change(order_item, :status).to('aborted') }
    end
  end
end
