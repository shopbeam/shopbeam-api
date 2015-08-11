require 'rails_helper'

describe Checkout::Partners do
  describe '.lookup' do
    subject { described_class.lookup(url) }

    context 'for well.ca' do
      let(:url) { 'https://well.ca/products/foo-bar.html' }

      it { is_expected.to eq(Checkout::Partners::WellCa) }
    end

    context 'for unsupported url' do
      let(:url) { 'http://foo.com/' }

      it { expect { subject }.to raise_error("Checkout partner not supported for 'http://foo.com/'") }
    end
  end
end
