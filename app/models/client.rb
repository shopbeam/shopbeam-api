class Client < ActiveRecord::Base
  include TokenAuthenticatable

  has_auth_token

  has_many :consumers
end
