class User < ActiveRecord::Base
  # TODO: replace Spock password encryption with has_secure_password
  PASSWORD_SALT_SIZE = 64
  PASSWORD_HASH_ITERATIONS = 2048
  PASSWORD_KEY_LENGTH = 256

  self.table_name = 'User'

  has_many :orders, class_name: 'Order', foreign_key: 'UserId'

  alias_attribute :first_name, :firstName
  alias_attribute :last_name, :lastName
  alias_attribute :api_key, :apiKey

  before_create :hash_password

  def proxy_user(partner_type)
    ProxyUser.find_by(user: self, partner_type: partner_type)
  end

  private

  def hash_password
    self.salt = PASSWORD_HASH_ITERATIONS.to_s(16) + '.' + SecureRandom.base64(PASSWORD_SALT_SIZE)
    self.password = Base64.strict_encode64(OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, PASSWORD_HASH_ITERATIONS, PASSWORD_KEY_LENGTH))
  end
end
