class Product < ActiveRecord::Base
  include PgSearch

  self.table_name = 'Product'

  belongs_to :brand, foreign_key: 'BrandId'
  has_one :partner, through: :brand
  has_many :variants,           -> { where(status: 1) }, foreign_key: 'ProductId'
  has_many :images,             -> { where(status: 1) }, through:     :variants
  has_many :product_categories, -> { where(status: 1) }, foreign_key: 'ProductId'
  has_many :categories,         -> { where(status: 1) }, through:     :product_categories

  pg_search_scope(
    :search,
    against: :searchText,
    using: {
      tsearch: {
        dictionary: 'english',
        tsvector_column: 'tsv'
      }
    },
    order_within_rank: '"Product"."createdAt" DESC'
  )

  delegate :id, :name, to: :brand, prefix: true
  delegate :id, :commission, :name, :linkshare_id, to: :partner, prefix: true

  alias_attribute :min_price_cents, :minPriceCents
  alias_attribute :max_price_cents, :maxPriceCents
  alias_attribute :brand_id, :BrandId
end
