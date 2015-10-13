class Batch
  attr_reader :batch_id

  def initialize(name)
    @batch_id = "#{name}-#{Time.now.to_f}"
  end

  def jobs
    ThreadStorage[:batch_id] = batch_id
    yield
    self
  ensure
    ThreadStorage[:batch_id] = nil
  end

  def after
    ThreadStorage[:batch_id] = batch_id
    ThreadStorage[:callback] = true
    yield
  ensure
    ThreadStorage[:batch_id] = nil
    ThreadStorage[:callback] = false
  end
end
