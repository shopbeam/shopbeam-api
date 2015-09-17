class OrdersController < ApplicationController
  def fill
    CheckoutJob.perform_later(params[:id])
    head :accepted
  end

  def mail
    return head :not_acceptable unless valid_signature?

    Checkout::MailDispatchers
      .lookup(params[:sender]).new(params)
      .call

    head :ok
  end

  private

  def valid_signature?
    digest = OpenSSL::Digest::SHA256.new
    data = [params[:timestamp], params[:token]].join
    signature = OpenSSL::HMAC.hexdigest(digest, Rails.application.secrets.mailgun_api_key, data)

    params[:signature] == signature
  end
end
