require 'rails_helper'
require 'redis_helper'

describe Batch::RedisStorage do
  context ".failed" do
    subject { described_class.new("some_batch", "some_job") }

    it "should mark job as failed after 3-rd error" do
      subject.started
      subject.failed
      expect(subject.retry?).to be_truthy
      expect(subject.failed?).to be_falsy
      expect(subject.finished?).to be_falsy
      subject.failed
      subject.failed
      expect(subject.retry?).to be_truthy
      expect(subject.failed?).to be_falsy
      expect(subject.finished?).to be_falsy
      subject.failed

      expect(subject.retry?).to be_falsy
      expect(subject.failed?).to be_truthy
      expect(subject.finished?).to be_falsy
    end
  end
end
