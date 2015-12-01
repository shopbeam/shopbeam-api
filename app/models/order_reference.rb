class OrderReference < ActiveRecord::Base
  belongs_to :order

  validates :order, :partner_type, presence: true
  validates :number, presence: true, uniqueness: { scope: :partner_type }
end
