class Order < ActiveRecord::Base
  include AASM

  self.table_name = 'Order'

  store_accessor :info,
                 :customer_first_name,
                 :customer_last_name,
                 :customer_company,
                 :customer_job_title,
                 :customer_mobile_phone,
                 :customer_email

  belongs_to :user, foreign_key: 'UserId'
  belongs_to :shipping_address, foreign_key: 'ShippingAddressId'
  belongs_to :billing_address, foreign_key: 'BillingAddressId'
  belongs_to :payment, foreign_key: 'PaymentId'
  has_many :order_items, foreign_key: 'OrderId', autosave: true
  has_many :partners, -> { distinct }, through: :order_items
  has_many :references, class_name: 'OrderReference'

  delegate :first_name, :last_name, :email,
           to: :user,
           prefix: true
  delegate :address1, :address2, :city, :state, :country, :zip, :phone_number,
           to: :shipping_address,
           prefix: :shipping
  delegate :address1, :address2, :city, :state, :country, :zip, :phone_number,
           to: :billing_address,
           prefix: :billing
  delegate :name, :brand, :number, :cvv, :expiration_month, :expiration_year,
           to: :payment,
           prefix: :cc

  alias_attribute :order_total_cents, :orderTotalCents
  alias_attribute :shipping_cents, :shippingCents
  alias_attribute :tax_cents, :taxCents
  alias_attribute :source_url, :sourceUrl
  alias_attribute :created_at, :createdAt

  enum status: {
    pending: 9,
    completed: 11,
    aborted: 8,
    test: 4
  }

  scope :uncompleted, -> { where.not(status: statuses.values_at(:completed, :test)) }

  aasm column: :status do
    state :pending, initial: true
    state :completed
    state :aborted
    state :test

    event :process do
      transitions to: :pending, unless: :completed?,
                  after: -> { transit_order_items(:process) }
    end

    event :complete do
      transitions from: :pending,
                  to: :completed,
                  after: -> {
                    transit_order_items(:complete)
                    payment.flush!
                  }
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

  def total_cents
    order_total_cents + shipping_cents + tax_cents
  end

  def customer=(data)
    if data.is_a?(Hash)
      assign_attributes(
        customer_first_name:   data['firstName'],
        customer_last_name:    data['lastName'],
        customer_company:      data['company'],
        customer_job_title:    data['jobTitle'],
        customer_mobile_phone: data['mobilePhone'],
        customer_email:        data['email']
      )
    end
  end

  def save_reference!(partner_type, number)
    references.create!(partner_type: partner_type, number: number)
  end

  private

  def transit_order_items(event)
    order_items.each(&event)
  end
end
