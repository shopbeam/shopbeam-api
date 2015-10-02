class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :verify_authenticity_signature

  protected

  def verify_authenticity_signature
    head :unauthorized unless SignatureVerifier.verify(
      key: Rails.application.secrets.cipher_key,
      timestamp: request.headers['X-Timestamp'],
      token: request.headers['X-Auth-Token'],
      signature: request.headers['X-Auth-Signature']
    )
  end
end
