class Product < ActiveRecord::Base
  include API::V2::Entities::Product

  self.table_name = 'Product'

  belongs_to :brand, foreign_key: 'BrandId'
  has_many :partner, through: :brand
  has_many :product_category, -> { where(status: 1) }, foreign_key:   'ProductId'
  has_many :categories,       -> { where(status: 1) }, through:       :product_category
  has_many :variants,         -> { where(status: 1) }, foreign_key:   'ProductId'

  alias_attribute :min_price_cents, :minPriceCents
  alias_attribute :max_price_cents, :maxPriceCents
  alias_attribute :brand_id, :BrandId
end
