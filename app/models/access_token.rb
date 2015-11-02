class AccessToken < ActiveRecord::Base
  EXPIRES_IN = 2.weeks
  BUFFER_TIMEOUT = 5.seconds

  belongs_to :consumer

  has_secure_token :fingerprint
  has_secure_token # :token

  scope :expired, -> { where('expires_at < ?', Time.now) }

  validates :consumer, presence: true

  before_create :record_expires_at

  def expired?
    expires_at < Time.now
  end

  def reusable?
    updated_at > Time.now - BUFFER_TIMEOUT
  end

  def regenerate!
    self.prev_token = token
    regenerate_token # provided by has_secure_token
  end

  private

  def record_expires_at
    self.expires_at = Time.now + EXPIRES_IN
  end
end
