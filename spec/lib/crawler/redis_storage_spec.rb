require 'rails_helper'
require 'redis_helper'

describe Crawler::RedisStorage do
  let(:name1) { 'name' }
  let(:name2) { 'other' }
  let(:key1) { 'some key' }
  let(:key2) { 'other key' }
  let(:value1) { 'some data' }
  let(:value2) { [1, 2, 3] }

  describe ".push" do
    before { described_class.new(name1).push(key1, value1) }

    it "saves key value in redis hash" do
      r = Redis.new
      expect(described_class.new(name1).all).to eq({ key1 => value1 })
    end

  end

  describe ".all" do
    subject { described_class.new(name1).all }

    context "zero case" do
      it { is_expected.to eq({}) }
    end

    context "normal case" do
      before do
        described_class.new(name1).push(key1, value1)
        described_class.new(name1).push(key2, value2)
      end

      it { is_expected.to eq({key1 => value1, key2 => value2}) }
    end
  end
end
