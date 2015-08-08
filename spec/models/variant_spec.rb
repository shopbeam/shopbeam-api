require 'rails_helper'

describe Variant do
  describe '#source_url' do
    it 'aliases to #sourceUrl' do
      variant = build_stubbed(described_class, sourceUrl: 'foo url')
      expect(variant.source_url).to eq('foo url')
    end
  end
end
