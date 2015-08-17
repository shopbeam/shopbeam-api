class Order < ActiveRecord::Base
  self.table_name = 'Order'

  belongs_to :user, foreign_key: 'UserId'
  belongs_to :shipping_address, foreign_key: 'ShippingAddressId'
  belongs_to :billing_address, foreign_key: 'BillingAddressId'
  has_many :order_items, foreign_key: 'OrderId'

  delegate :address1, :address2, :city, :state, :zip, to: :shipping_address, prefix: :shipping
  delegate :address1, :address2, :city, :state, :zip, to: :billing_address, prefix: :billing
end
