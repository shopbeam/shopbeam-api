class Consumer < ActiveRecord::Base
  belongs_to :client

  attr_accessor :access_token

  has_secure_password

  has_many :access_tokens, dependent: :destroy

  delegate :fingerprint, :token, :expires_at, to: :access_token

  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :client, presence: true

  before_save :record_email
  before_create :build_access_token

  class Entity < Grape::Entity
    expose :id, :email, :created_at, :updated_at
  end

  def delete_expired_tokens
    access_tokens.expired.delete_all
  end

  private

  def record_email
    self.email = email.downcase
  end

  def build_access_token
    self.access_token = access_tokens.build
  end
end
