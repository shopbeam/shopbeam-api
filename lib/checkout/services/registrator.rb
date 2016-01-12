module Checkout
  module Services
    class Registrator
      include Wisper::Publisher

      def call(account_id)
        account = Account.inactive.find(account_id)
        registrator = Checkout::Registrators.lookup!(account.partner_type)

        account.process!

        registrator.new(account).register!
      rescue ActiveRecord::RecordNotFound
        broadcast :account_not_found, account_id
      rescue StandardError => exception
        account.abort!
        broadcast :account_aborted, account, exception
        raise
      else
        account.activate!
        broadcast :account_activated, account
      end
    end
  end
end
