module Crypto
  module Pkcs5
    KEY = ENV['OLD_KEY']

    extend self

    def encrypt(value)
      crypt(value, :encrypt).unpack('H*').first
    end

    def decrypt(value)
      value = [value].pack('H*')
      crypt(value, :decrypt)
    end

    private

    def crypt(value, mode)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.send(mode)
      cipher.pkcs5_keyivgen(KEY, nil, 1)
      cipher.update(value) + cipher.final
    end
  end

  module Pbkdf2
    KEY = ENV['NEW_KEY']
    DEFAULT_HASH_ITERATIONS = 2048
    SALT_SIZE = 16
    KEY_LENGTH = 32

    extend self

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

class EncryptCcNumbersWithMessageEncryptor < ActiveRecord::Migration
  class Payment < ActiveRecord::Base
    self.table_name = 'Payment'
    self.inheritance_column = nil
  end

  def up
    payments_encrypted = Payment.find_each.with_object({}) do |payment, result|
      payload = {}

      payload[:pkcs5_encrypted_before_pbkdf2] = payment.number
      payload[:pkcs5_decrypted] = Crypto::Pkcs5.decrypt(payment.number)
      pbkdf2 = Crypto::Pbkdf2.encrypt(payload[:pkcs5_decrypted])
      payload[:pbkdf2_encrypted] = {
        value: pbkdf2[:value],
        salt: pbkdf2[:salt]
      }
      payload[:pbkdf2_decrypted] = Crypto::Pbkdf2.decrypt(
        payload[:pbkdf2_encrypted][:value],
        payload[:pbkdf2_encrypted][:salt]
      )
      payload[:pkcs5_encrypted_after_pbkdf2] = Crypto::Pkcs5.encrypt(payload[:pbkdf2_decrypted])

      # Verify pkcs5 <=> pbkdf2 transition
      unless (payload[:pkcs5_decrypted] === payload[:pkcs5_decrypted]) &&
             (payload[:pkcs5_encrypted_before_pbkdf2] === payload[:pkcs5_encrypted_after_pbkdf2])
        raise ActiveRecord::Rollback, "Bad decrypt for Payment##{payment.id}"
      end

      say "[OK] Payment##{payment.id}", true

      # Prepare payment attributes
      result[payment.id] = {
        number: payload[:pbkdf2_encrypted][:value],
        numberSalt: payload[:pbkdf2_encrypted][:salt]
      }
    end

    Payment.update(payments_encrypted.keys, payments_encrypted.values)
  end

  def down
    payments_encrypted = Payment.find_each.with_object({}) do |payment, result|
      payload = {}

      payload[:pbkdf2_encrypted] = payment.number
      payload[:pbkdf2_decrypted] = Crypto::Pbkdf2.decrypt(
        payment.number,
        payment.numberSalt
      )
      payload[:pkcs5_encrypted] = Crypto::Pkcs5.encrypt(payload[:pbkdf2_decrypted])
      payload[:pkcs5_decrypted] = Crypto::Pkcs5.decrypt(payload[:pkcs5_encrypted])

      # Verify pbkdf2 <=> pkcs5 transition
      unless payload[:pbkdf2_decrypted] === payload[:pkcs5_decrypted]
        raise ActiveRecord::Rollback, "Bad decrypt for Payment##{payment.id}"
      end

      say "[OK] Payment##{payment.id}", true

      # Prepare payment attributes
      result[payment.id] = {
        number: payload[:pkcs5_encrypted],
        numberSalt: nil
      }
    end

    Payment.update(payments_encrypted.keys, payments_encrypted.values)
  end
end
