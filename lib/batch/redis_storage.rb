class Batch
  class RedisStorage
    EXPIRE_TIME = 86400 # 24 hours * 60 minutes * 60 seconds

    def initialize(batch_id, job_id=nil)
      @batch_id = batch_id
      @job_id = job_id
    end

    def registered
      set_status :registered unless finished?
    end

    def started
      return if retry?
      set_status :started
    end

    def failed
      status = case job_status
      when :started
        :retry1
      when :retry1
        :retry2
      when :retry2
        :retry3
      else
        :failed
      end
      set_status status
    end

    def failed?
      job_status == :failed
    end

    def finished
      set_status :finished
    end

    def finished?
      job_status == :finished
    end

    def retry?
      [:retry1, :retry2, :retry3].include?(job_status)
    end

    def batch_jobs
      Sidekiq.redis do |conn|
        conn.hgetall storage_key
      end
    end

    private
    def set_status(value)
      Sidekiq.redis do |conn|
        conn.hmset storage_key, @job_id, value
        conn.expire storage_key, EXPIRE_TIME
      end
    end

    def job_status
      batch_jobs[@job_id].try(:to_sym)
    end

    def storage_key
      "batch-#{@batch_id}"
    end
  end
end
