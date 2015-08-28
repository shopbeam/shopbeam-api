require 'rails_helper'

describe User do
  describe '#first_name' do
    it 'is an alias of #firstName' do
      user = described_class.new(firstName: 'foo first name')

      expect(user.first_name).to eq('foo first name')
    end
  end

  describe '#last_name' do
    it 'is an alias of #lastName' do
      user = described_class.new(lastName: 'foo last name')

      expect(user.last_name).to eq('foo last name')
    end
  end
end
