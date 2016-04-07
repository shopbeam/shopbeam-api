class OrderItem < ActiveRecord::Base
  include AASM

  self.table_name = 'OrderItem'

  belongs_to :variant, foreign_key: 'VariantId'
  has_one :product, through: :variant

  delegate :source_url, :color, :size, to: :variant

  alias_attribute :sale_price_cents, :salePriceCents
  alias_attribute :list_price_cents, :listPriceCents

  enum status: {
    pending: 9,
    processed: 12,
    out_of_stock: 5,
    unprocessed: 13,
    aborted: 14
  }

  aasm column: :status, whiny_transitions: false do
    state :pending, initial: true
    state :processed
    state :out_of_stock
    state :unprocessed
    state :aborted

    event :process do
      transitions to: :pending
    end

    event :complete do
      transitions from: :pending, to: :processed
    end

    event :mark_as_out_of_stock do
      transitions from: :pending, to: :out_of_stock
    end

    event :terminate do
      transitions from: :pending, to: :unprocessed
    end

    event :abort do
      transitions from: :pending, to: :aborted
    end
  end

  def bot
    Checkout::Bots.lookup!(source_url)
  end
end
