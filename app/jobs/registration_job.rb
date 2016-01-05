class RegistrationJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(account_id)
    Checkout::Services::Registrator.new
      .subscribe(Checkout::Notifier.new)
      .call(account_id)
  end
end
