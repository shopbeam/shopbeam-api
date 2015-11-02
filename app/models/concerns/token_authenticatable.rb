module TokenAuthenticatable
  extend ActiveSupport::Concern

  class_methods do
    def has_auth_token
      has_one :auth_token, as: :owner, dependent: :destroy

      delegate :key, :secret, to: :auth_token, prefix: :api

      before_create :build_auth_token
    end
  end
end
