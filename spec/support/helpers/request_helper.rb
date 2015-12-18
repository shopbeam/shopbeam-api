module RequestHelper
  def verify_authenticity_signature
    signature = generate_signature(Rails.application.secrets.cipher_key)

    request.headers.merge!(
      'X-Timestamp'      => signature[:timestamp],
      'X-Auth-Token'     => signature[:token],
      'X-Auth-Signature' => signature[:signature]
    )
  end

  def mailgun_signature
    generate_signature(Rails.application.secrets.mailgun_api_key)
  end

  private

  def generate_signature(key)
    timestamp = Time.now.to_i
    token     = SecureRandom.hex(25)
    digest    = OpenSSL::Digest::SHA256.new
    data      = [timestamp, token].join
    signature = OpenSSL::HMAC.hexdigest(digest, key, data)

    {
      :timestamp => timestamp,
      :token     => token,
      :signature => signature
    }
  end
end
