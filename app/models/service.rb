class Service < ActiveRecord::Base
  include TokenAuthenticatable

  has_auth_token

  validates :name, presence: true
end
