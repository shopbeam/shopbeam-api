class Order < ActiveRecord::Base
  include AASM

  self.table_name = 'Order'

  belongs_to :user, foreign_key: 'UserId'
  belongs_to :shipping_address, foreign_key: 'ShippingAddressId'
  belongs_to :billing_address, foreign_key: 'BillingAddressId'
  belongs_to :payment, foreign_key: 'PaymentId'
  has_many :order_items, foreign_key: 'OrderId'

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
    terminated: 10,
    aborted: 8
  }

  aasm column: :status do
    state :pending, initial: true
    state :completed
    state :terminated
    state :aborted

    event :process do
      transitions to: :pending, unless: :completed?
    end

    event :finish do
      transitions from: :pending, to: :completed, if: :all_items_processed?
      transitions from: :pending, to: :aborted, if: :any_item_aborted?
      transitions from: :pending, to: :terminated
    end
  end

  private

  def all_items_processed?
    order_items.all?(&:processed?)
  end

  def any_item_aborted?
    order_items.any?(&:aborted?)
  end
end
