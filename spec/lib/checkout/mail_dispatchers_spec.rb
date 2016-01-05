require 'rails_helper'

describe Checkout::MailDispatchers do
  describe '.lookup' do
    context 'for WellCa' do
      it { expect(described_class.lookup('info@well.ca')).to eq(Checkout::WellCa::MailDispatcher) }
    end

    # TODO: Temporarily disable Lacoste partner
    # context 'for LacosteComUs' do
    #   %w(no-reply@lacoste.us noreply@lacoste.com noreply-staging@lacoste.com).each do |from|
    #     it { expect(described_class.lookup(from)).to eq(Checkout::LacosteComUs::MailDispatcher) }
    #   end
    # end
  end
end
