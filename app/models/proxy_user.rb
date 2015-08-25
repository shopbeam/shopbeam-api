class ProxyUser < ActiveRecord::Base
  EMAIL_DOMAIN = 'checkout.shopbeam.com'.freeze

  belongs_to :user

  delegate :first_name, :last_name, to: :user, allow_nil: true

  validates :user, presence: true, uniqueness: { scope: :provider_type }
  validates :provider_type, :password, :password_salt, presence: true
  validates :email, presence: true, uniqueness: true

  after_initialize :set_defaults, if: :new_record?

  def password
    Encryptor.decrypt(read_attribute(:password), read_attribute(:password_salt))
  end

  def password=(value)
    encrypted = Encryptor.encrypt(value)
    write_attribute(:password, encrypted[:value])
    write_attribute(:password_salt, encrypted[:salt])
  end

  private

  def set_defaults
    self.email = "#{first_name}.#{last_name}.#{SecureRandom.hex(2)}".parameterize << "@#{EMAIL_DOMAIN}"
    self.password = SecureRandom.hex(6)
  end
end
