class Batch
  class Job
    include Sidekiq::Worker
    sidekiq_options retry: 4, backtrace: 5

    class << self
      def perform_async(*args)
        batch_id = ThreadStorage[:batch_id]
        callback = ThreadStorage[:callback]
        job_id = super(*args, batch_id: batch_id, callback: callback)
        Batch::RedisStorage.new(batch_id, job_id).registered unless callback
        job_id
      end
    end

    def perform(*args)
      batch_args = args.pop.symbolize_keys
      @batch_id = batch_args[:batch_id]
      is_callback = batch_args[:callback]
      if is_callback
        perform_callback(*args)
      else
        perform_job(*args)
      end
    end

    def perform_job(*args)
      add_newrelic_params
      storage.started
      run(*args)
      storage.finished
    rescue => e
      storage.failed
      on_error(e)
      raise e
    end

    def perform_callback(*args)
      all_jobs_finished = batch_jobs.all? {|job_id, status| ['finished', 'failed'].include?(status) }
      if all_jobs_finished
        run(*args)
      else
        self.class.perform_in(10.seconds, *args, batch_id: @batch_id, callback: true)
      end
    end

    def add_to_batch
      ThreadStorage[:batch_id] = @batch_id
      yield
      self
    ensure
      ThreadStorage[:batch_id] = nil
    end

    def run(*)
      fail NotImplementedError
    end

    def on_error(exception)
      add_newrelic_params
    end

    def add_newrelic_params
      ::NewRelic::Agent.add_custom_attributes(batch_id: @batch_id, jid: @jid)
    end

    def storage
      @storage ||= Batch::RedisStorage.new(@batch_id, @jid)
    end

    def batch_jobs
      storage.batch_jobs.select {|job_id, status| job_id != @jid}
    end
  end
end
