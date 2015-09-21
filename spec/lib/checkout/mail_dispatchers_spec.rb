require 'rails_helper'

describe Checkout::MailDispatchers do
  describe '.lookup' do
    subject { described_class.lookup(from) }

    context 'for well.ca' do
      let(:from) { 'info@well.ca' }

      it { is_expected.to eq(Checkout::WellCa::MailDispatcher) }
    end

    context 'for lacoste.com' do
      let(:from) { 'noreply-staging@lacoste.com' }

      it { is_expected.to eq(Checkout::LacosteComUs::MailDispatcher) }
    end

    context 'for lacoste.us' do
      let(:from) { 'no-reply@lacoste.us' }

      it { is_expected.to eq(Checkout::LacosteComUs::MailDispatcher) }
    end
  end
end
