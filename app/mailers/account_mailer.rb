class AccountMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def activated(account)
    @account = account

    mail subject: "[order-manager] Shopbeam account ##{@account.id} has been successfully registered"
  end

  def not_found(account_id)
    @account_id = account_id

    mail subject: "[order-manager] Shopbeam account ##{@account_id} not found"
  end

  def aborted(account, exception)
    @account = account
    @exception = exception

    mail subject: "[order-manager] ACTION REQUIRED: Registration of Shopbeam account ##{@account.id} has been aborted"
  end
end
