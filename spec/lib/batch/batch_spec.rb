require 'rails_helper'
require 'redis_helper'
require 'sidekiq/testing'

describe Batch do
  Storage = {}
  before { Storage.clear }
  let(:name) { 'some name' }
  subject { described_class.new(name) }

  it "should set batch_id" do
    expect(subject.instance_variable_get(:@batch_id)).to include(name)
  end

  context ".jobs" do
    let(:args) { [44, 's', {'a' => 1}] }
    let!(:sample_job) do
      class SampleJob < Batch::Job
        def run(*args)
          Storage[:result] = @batch_id
          Storage[:args] = args
        end
      end
    end

    subject do
      Sidekiq::Testing.inline! do
        described_class.new(name).jobs do
          SampleJob.perform_async(*args)
        end
      end
      Storage
    end

    it "exposes batch_id variable to jobs" do
      expect(subject[:result]).to include(name)
    end

    it "pass all arguments to job .run method" do
      expect(subject[:args]).to eq(args)
    end

    it "mark job as queued" do
      job_id = nil
      batch = described_class.new(name)
        batch.jobs do
          job_id = SampleJob.perform_async(*args)
        end
      expect(Batch::RedisStorage.new(batch.batch_id, job_id).send(:job_status)).to eq :registered
    end

    it "mark job as done" do
      expect_any_instance_of(Batch::RedisStorage).to receive(:finished)
      subject
    end

    context "job raises exception" do
      let!(:sample_job) do
        class SampleJob < Batch::Job
          def run(*args)
            raise "some error"
          end
        end
      end

      subject do
        Sidekiq::Testing.inline! do
          batch = described_class.new(name)
          batch.jobs do
            SampleJob.perform_async(*args)
          end
        end
      end

      it "mark job as failed" do
        expect_any_instance_of(Batch::RedisStorage).to receive(:failed)
        expect{ subject }.to raise_error("some error")
      end

      it "calls error callback" do
        expect_any_instance_of(SampleJob).to receive(:on_error)
        expect{ subject }.to raise_error("some error")
      end

      it "sends email notification by default" do
        ActionMailer::Base.deliveries.clear
        expect{ subject }.to raise_error("some error")
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end
    end

    context ".after callback" do
      let!(:callback) do
        class SampleCallback < Batch::Job
          def run(*args)
            Storage[:callback_done] = true
          end
        end
      end

      subject do
        Sidekiq::Testing.inline! do
          described_class.new(name).jobs do
            SampleJob.perform_async(*args)
          end.after do
            SampleCallback.perform_async(*args)
          end
        end
        Storage
      end

      it "runs callback after all jobs done" do
        expect(subject[:callback_done]).to be_truthy
      end
    end
  end

  context ".add_to_batch" do
    let!(:sample_job) do
      class SampleJob < Batch::Job
        def run(*args)
          Storage[:result_run1] = true
          add_to_batch do
            ChildJob.perform_async
          end
        end
      end
    end

    let!(:child_job) do
      class ChildJob < Batch::Job
        def run
          Storage[:result_run2] = true
        end
      end
    end

    subject do
      Sidekiq::Testing.inline! do
        described_class.new(name).jobs do
          SampleJob.perform_async
        end
      end
      Storage
    end

    it "should run parent and child job" do
      expect(subject[:result_run1]).to be_truthy
      expect(subject[:result_run2]).to be_truthy
    end
  end
end
