require 'rails_helper'

describe Checkout::Providers do
  describe '.lookup' do
    subject { described_class.lookup(url) }

    context 'for well.ca' do
      let(:url) { 'https://well.ca/products/foo-bar.html' }

      it { is_expected.to eq(Checkout::Providers::WellCa) }
    end

    context 'for unsupported url' do
      let(:url) { 'http://foo.com/' }

      it { expect { subject }.to raise_error("Checkout provider not supported for 'http://foo.com/'") }
    end
  end
end
