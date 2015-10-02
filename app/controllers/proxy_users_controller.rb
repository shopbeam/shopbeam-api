class ProxyUsersController < ApplicationController
  skip_before_action :verify_authenticity_signature, only: :unsubscribe

  def unsubscribe
    proxy_user = ProxyUser.find_by_signature(params[:signature])

    if proxy_user.subscribed?
      proxy_user.update_attribute(:subscribed, false)
      render plain: 'You have been successfully unsubscribed from email communications'
    else
      render plain: 'You already were unsubscribed as per your request'
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature,
         ActiveRecord::RecordNotFound
    render plain: 'Invalid link'
  end
end
