require 'rails_helper'

describe Checkout::Registrators do
  describe '.lookup!' do
    context 'for hilton.com' do
      it { expect(described_class.lookup!('HiltonCom')).to eq(Checkout::HiltonCom::Registrator) }
    end

    context 'for unsupported partner' do
      it { expect { described_class.lookup!('FakePartner') }.to raise_error(Checkout::PartnerNotSupportedError, /Account registrator not supported/) }
    end
  end
end
