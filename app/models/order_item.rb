class OrderItem < ActiveRecord::Base
  include AASM

  self.table_name = 'OrderItem'

  belongs_to :variant, foreign_key: 'VariantId'
  delegate :source_url, to: :variant, prefix: true
  alias_attribute :sale_price_cents, :salePriceCents

  enum status: {
    pending: 9,
    processed: 12,
    out_of_stock: 5,
    unprocessed: 13,
    aborted: 14
  }

  aasm column: :status do
    state :pending, initial: true
    state :processed
    state :out_of_stock
    state :unprocessed
    state :aborted

    event :process do
      transitions to: :pending, unless: :processed?
    end

    event :mark_as_processed do
      transitions from: :pending, to: :processed
    end

    event :mark_as_out_of_stock do
      transitions from: :pending, to: :out_of_stock
    end

    event :mark_as_unprocessed do
      transitions from: :pending, to: :unprocessed
    end

    event :abort do
      transitions from: :pending, to: :aborted
    end
  end
end
