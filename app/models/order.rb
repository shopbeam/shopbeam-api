class Order < ActiveRecord::Base
  self.table_name = 'Order'

  belongs_to :user, foreign_key: 'UserId'
  has_many :order_items, foreign_key: 'OrderId'
end
