class CheckoutJob < ActiveJob::Base
  MAX_RETRIES = 3

  queue_as :default

  rescue_from(StandardError) do |exception|
    raise exception if @attempt_number > MAX_RETRIES
    retry_job queue: :default
  end

  def serialize
    super.merge('attempt_number' => (@attempt_number || 0) + 1)
  end

  def deserialize(job_data)
    super
    @attempt_number = job_data['attempt_number']
  end

  def perform(order_id)
    order = Order.find(order_id)

    Checkout::Shopper.call(order, Checkout::Notifier.new)
  end
end
