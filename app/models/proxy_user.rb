class ProxyUser < ActiveRecord::Base
  EMAIL_DOMAIN = 'checkout.shopbeam.com'.freeze

  belongs_to :user

  delegate :first_name, :last_name, to: :user, allow_nil: true
  delegate :email, to: :user, prefix: true

  validates :user, presence: true, uniqueness: { scope: :partner_type }
  validates :partner_type, :password, :password_salt, presence: true
  validates :email, presence: true, uniqueness: true

  after_initialize :set_defaults, if: :new_record?

  def password
    Encryptor.decrypt(read_attribute(:password), read_attribute(:password_salt))
  end

  private

  attr_writer :email, :password

  def set_defaults
    encrypted_password = Encryptor.encrypt(SecureRandom.hex(6))

    write_attribute(:email, "#{first_name}.#{last_name}.#{SecureRandom.hex(2)}".parameterize << "@#{EMAIL_DOMAIN}")
    write_attribute(:password, encrypted_password[:value])
    write_attribute(:password_salt, encrypted_password[:salt])
  end
end
