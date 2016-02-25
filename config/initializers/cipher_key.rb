require 'open-uri'

if Rails.env.production?
  encrypted_key = Rails.root.join('config', 'cipher_key.asc')

  unless File.exists?(encrypted_key)
    raise 'Could not load cipher key. No such file - ["config/cipher_key.asc"]'
  end

  begin
    # GnuPG 2.x does not support headless password callback, select GnuPG 1.x as an engine
    GPGME::gpgme_set_engine_info(GPGME::PROTOCOL_OpenPGP, `which gpg`.strip, GPGME::Engine.dirinfo('homedir'))

    crypto = GPGME::Crypto.new

    # Calculate key passphrase from private hostname of the EC2 instance
    hostname = open('http://169.254.169.254/latest/meta-data/hostname').read
    password = Digest::SHA256.hexdigest(hostname)

    decrypted_key = crypto.decrypt(File.open(encrypted_key), password: password)

    CIPHER_KEY = decrypted_key.to_s
  rescue StandardError => exception
    raise "Could not decrypt cipher key. #{exception.message}"
  end
else
  CIPHER_KEY = Rails.application.secrets.cipher_key
end
