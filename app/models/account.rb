class Account < ActiveRecord::Base
  include AASM
  include AttrDecryptor

  attr_decryptor :password

  has_one :address, dependent: :destroy

  delegate :phone_number, :country, :address1, :address2, :city, :state, :zip,
           to: :address

  scope :inactive, -> { where.not(aasm_state: :active) }

  validates :partner_type, :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { scope: :partner_type }

  aasm do
    state :pending, initial: true
    state :active
    state :aborted

    event :process do
      transitions to: :pending, unless: :active?
    end

    event :activate do
      transitions from: :pending, to: :active
    end

    event :abort do
      transitions from: :pending, to: :aborted
    end
  end
end
