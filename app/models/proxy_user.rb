class ProxyUser < ActiveRecord::Base
  EMAIL_DOMAIN = 'checkout.shopbeam.com'.freeze

  belongs_to :user

  delegate :first_name, :last_name, to: :user, allow_nil: true

  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.email = "#{first_name}.#{last_name}.#{SecureRandom.hex(2)}".parameterize << "@#{EMAIL_DOMAIN}"
    self.password = SecureRandom.hex(6)
  end
end
