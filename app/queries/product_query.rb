class ProductQuery
  class << self
    delegate :call, to: :new
  end

  delegate :limit!, :offset!, to: :relation

  def initialize(relation: Product.all)
    @relation = relation
  end

  def to_s
    "#{self.class.name.underscore}_#{object_id}"
  end

  def call
    yield self if block_given?

    relation
      .joins(:brand, :partner, :variants)
      .includes(:brand, :partner, :variants, :categories)
      .where(Partner: { status: 1 }, Brand: { status: 1 }, status: 1)
  end

  def by_variant_id!(variant_id)
    relation.where!(Variant: { id: variant_id })
    self
  end

  def by_partner_id!(partner_id)
    relation.where!(Partner: { id: partner_id })
    self
  end

  def by_brand_id!(brand_id)
    relation.where!(Brand: { id: brand_id })
    self
  end

  def by_category_id!(category_id)
    relation.where!(Category: { id: category_id })
    self
  end

  def by_min_price!(min_price)
    relation.where!('COALESCE(NULLIF("Variant"."salePriceCents", 0), "Variant"."listPriceCents") >= ?', min_price)
    self
  end

  def by_max_price!(max_price)
    relation.where!('COALESCE(NULLIF("Variant"."salePriceCents", 0), "Variant"."listPriceCents") <= ?', max_price)
    self
  end

  def by_sale_percent!(sale_percent)
    relation
      .where!('"Variant"."salePriceCents" > 0')
      .where!('Round(("Variant"."listPriceCents"::Numeric - "Variant"."salePriceCents"::Numeric) / "Variant"."listPriceCents"::Numeric * 100) >= ?', sale_percent)

    self
  end

  def search!(term)
    relation.merge!(relation.search(term))
    self
  end

  def sort_by!(key)
    case key
    when :recent    then sort_by_date!
    when :lowtohigh then sort_by_min_price!
    when :hightolow then sort_by_max_price!
    when :relevance then sort_by_rank!
    end
  end

  private

  attr_reader :relation

  def sort_by_date!
    relation.reorder!(createdAt: :desc)
  end

  def sort_by_min_price!
    relation.joins!(<<-SQL
      INNER JOIN (
        SELECT "ProductId", MIN(COALESCE(NULLIF("salePriceCents", 0), "listPriceCents")) AS "minPriceCents"
        FROM "Variant"
        GROUP BY "ProductId"
      ) AS #{self} ON #{self}."ProductId" = "Product".id
    SQL
    ).reorder!("#{self}.\"minPriceCents\" ASC")
  end

  def sort_by_max_price!
    relation.joins!(<<-SQL
      INNER JOIN (
        SELECT "ProductId", MAX(COALESCE(NULLIF("salePriceCents", 0), "listPriceCents")) AS "maxPriceCents"
        FROM "Variant"
        GROUP BY "ProductId"
      ) AS #{self} ON #{self}."ProductId" = "Product".id
    SQL
    ).reorder!("#{self}.\"maxPriceCents\" DESC")
  end

  def sort_by_rank!
    # Handled in Product.pg_search_scope
  end
end
