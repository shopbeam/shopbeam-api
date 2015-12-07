class ProxyUsersController < ApplicationController
  skip_before_action :verify_authenticity_signature

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature,
              ActiveRecord::RecordNotFound,
              with: :invalid_link

  def unsubscribe
    @subscription = OpenStruct.new(proxy_user.subscription)
  end

  def confirm_unsubscribe
    proxy_user.update!(subscription: subscription_params)
    flash[:notice] = 'Your settings have been successfully saved'
    redirect_to unsubscribe_url
  end

  private

  def proxy_user
    ProxyUser.find_by_signature(params[:signature])
  end

  def subscription_params
    params.require(:subscription).permit(:orders, :promotions)
  end

  def invalid_link
    flash.now[:error] = 'Invalid link'
    render 'unsubscribe', status: :not_found
  end
end
