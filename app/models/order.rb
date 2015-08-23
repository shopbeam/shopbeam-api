class Order < ActiveRecord::Base
  include AASM

  self.table_name = 'Order'

  belongs_to :user, foreign_key: 'UserId'
  belongs_to :shipping_address, foreign_key: 'ShippingAddressId'
  belongs_to :billing_address, foreign_key: 'BillingAddressId'
  belongs_to :payment, foreign_key: 'PaymentId'
  has_many :order_items, foreign_key: 'OrderId', autosave: true

  delegate :first_name, :last_name, :address1, :address2, :city, :state, :zip,
           to: :shipping_address,
           prefix: :shipping
  delegate :first_name, :last_name, :address1, :address2, :city, :state, :zip,
           to: :billing_address,
           prefix: :billing
  delegate :name, :number, :cvv, :expiration_month, :expiration_year,
           to: :payment,
           prefix: :cc

  enum status: {
    pending: 9,
    completed: 11,
    aborted: 8
  }

  scope :uncompleted, -> { where.not(status: statuses[:completed]) }

  aasm column: :status do
    state :pending, initial: true
    state :completed
    state :aborted

    event :process do
      transitions to: :pending, unless: :completed?,
                  after: -> { transit_order_items(:process) }
    end

    event :complete do
      transitions from: :pending,
                  to: :completed,
                  after: -> { transit_order_items(:complete) }
    end

    event :terminate do
      transitions from: :pending,
                  to: :aborted,
                  after: -> { transit_order_items(:terminate) }
    end

    event :abort do
      transitions from: :pending,
                  to: :aborted,
                  after: -> { transit_order_items(:abort) }
    end
  end

  private

  def transit_order_items(event)
    order_items.each(&event)
  end
end
