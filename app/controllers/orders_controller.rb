class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_authenticity_signature, only: :mail

  def fill
    CheckoutJob.perform_async(params[:id], params[:customer])
    head :accepted
  end

  def mail
    return head :not_acceptable unless verify_mailgun_signature

    MailDispatcherJob.perform_async(params)
    head :ok
  end

  private

  def verify_mailgun_signature
    SignatureVerifier.verify(
      key: Rails.application.secrets.mailgun_api_key,
      timestamp: params[:timestamp],
      token: params[:token],
      signature: params[:signature]
    )
  end
end
