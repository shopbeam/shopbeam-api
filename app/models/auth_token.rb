class AuthToken < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  has_secure_token :key
  has_secure_token :secret

  validates :owner, presence: true
end
