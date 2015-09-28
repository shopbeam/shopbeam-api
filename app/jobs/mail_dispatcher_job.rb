class MailDispatcherJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(params)
    params.symbolize_keys!
    dispatcher = Checkout::MailDispatchers.lookup(params[:from])
    dispatcher.new(params).call if dispatcher
  end
end
