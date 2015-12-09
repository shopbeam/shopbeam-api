class ProxyUser < ActiveRecord::Base
  EMAIL_DOMAIN = 'orders.shopbeam.com'.freeze

  belongs_to :user
  has_many :orders, through: :user

  delegate :first_name, :last_name, to: :user, allow_nil: true
  delegate :email, to: :user, prefix: true

  serialize :subscription, Hash

  validates :user, presence: true, uniqueness: { scope: :partner_type }
  validates :partner_type, :password, :password_salt, presence: true
  validates :email, presence: true, uniqueness: true

  after_initialize :set_defaults, if: :new_record?

  def self.find_by_signature(signature)
    find(verifier.verify(signature))
  end

  def password
    Encryptor.decrypt(read_attribute(:password), read_attribute(:password_salt))
  end

  def signature
    self.class.signature(self)
  end

  def subscribed_to_orders?
    subscription[:orders] == '1'
  end

  private

  attr_writer :email, :password

  def self.signature(user)
    verifier.generate(user.id)
  end

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base)
  end

  def set_defaults
    encrypted_password = Encryptor.encrypt(SecureRandom.hex(6))

    write_attribute(:email, "#{first_name}.#{last_name}.#{SecureRandom.hex(2)}".parameterize << "@#{EMAIL_DOMAIN}")
    write_attribute(:password, encrypted_password[:value])
    write_attribute(:password_salt, encrypted_password[:salt])
  end
end
