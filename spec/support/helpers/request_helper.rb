module RequestHelper
  def verify_signature
    key       = Rails.application.secrets.cipher_key
    timestamp = Time.now.to_i
    token     = SecureRandom.hex(25)
    digest    = OpenSSL::Digest::SHA256.new
    data      = [timestamp, token].join
    signature = OpenSSL::HMAC.hexdigest(digest, key, data)

    request.headers.merge!(
      'X-Timestamp'      => timestamp,
      'X-Auth-Token'     => token,
      'X-Auth-Signature' => signature
    )
  end
end
