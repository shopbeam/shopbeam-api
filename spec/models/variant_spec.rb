require 'rails_helper'

describe Variant do
  describe '#source_url' do
    it 'is an alias of #sourceUrl' do
      variant = described_class.new(sourceUrl: 'foo url')

      expect(variant.source_url).to eq('foo url')
    end
  end
end
