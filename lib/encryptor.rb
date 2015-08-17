module Encryptor
  KEY = Rails.application.secrets.cipher_key
  DEFAULT_HASH_ITERATIONS = 2048
  SALT_SIZE = 16
  KEY_LENGTH = 32

  class << self
    def encrypt(value)
      salt = SecureRandom.random_bytes(SALT_SIZE)
      key = ActiveSupport::KeyGenerator.new(KEY, iterations: DEFAULT_HASH_ITERATIONS).generate_key(salt, KEY_LENGTH)
      crypt = ActiveSupport::MessageEncryptor.new(key, serializer: ActiveSupport::MessageEncryptor::NullSerializer)

      {
        value: crypt.encrypt_and_sign(value),
        salt: Base64.strict_encode64(salt)
      }
    end

    def decrypt(value, salt)
      salt = Base64.strict_decode64(salt)
      key = ActiveSupport::KeyGenerator.new(KEY, iterations: DEFAULT_HASH_ITERATIONS).generate_key(salt, KEY_LENGTH)
      crypt = ActiveSupport::MessageEncryptor.new(key, serializer: ActiveSupport::MessageEncryptor::NullSerializer)

      crypt.decrypt_and_verify(value)
    end
  end
end
