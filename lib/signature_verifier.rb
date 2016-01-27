module SignatureVerifier
  def self.verify(key:, digest: 'sha256', signature:, **data)
    return false unless signature

    digest = OpenSSL::Digest.new(digest)
    data = data.values.join
    OpenSSL::HMAC.hexdigest(digest, key, data) == signature
  end
end
