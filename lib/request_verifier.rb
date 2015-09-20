module RequestVerifier
  def self.verify(key: Rails.application.secrets.cipher_key, timestamp:, token:, signature:)
    digest = OpenSSL::Digest::SHA256.new
    data = [timestamp, token].join

    OpenSSL::HMAC.hexdigest(digest, key, data) == signature
  end
end
