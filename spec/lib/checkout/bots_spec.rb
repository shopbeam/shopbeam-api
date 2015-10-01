require 'rails_helper'

describe Checkout::Bots do
  describe '.lookup!' do
    subject { described_class.lookup!(url) }

    context 'for well.ca' do
      let(:url) { 'https://well.ca/foo-bar.html' }

      it { is_expected.to eq(Checkout::WellCa::Bot) }
    end

    context 'for lacoste.com/us' do
      let(:url) { 'https://www.lacoste.com/us/foo-bar.html' }

      it { is_expected.to eq(Checkout::LacosteComUs::Bot) }
    end

    context 'for unsupported url' do
      let(:url) { 'http://foo.com/' }

      it { expect { subject }.to raise_error('PartnerNotSupportedError: The following error(s) occurred on http://foo.com/: Checkout partner not supported.') }
    end
  end
end
