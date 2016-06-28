class PartnerQuery
  class << self
    delegate :call, to: :new
  end

  def initialize(relation: Partner.all)
    @relation = relation
  end

  def call
    yield self if block_given?

    relation.active
      .joins(:details)
      .eager_load(details: :shipping_items)
      .order('
        "Partner".id,
        "PartnerDetail".state,
        "PartnerDetail".zip,
        "ItemCountShippingCost"."itemCount"
      ')
  end

  def by_partner_id!(partner_id)
    self.relation = relation.where(id: partner_id)
    self
  end

  def by_state!(state)
    self.relation = relation.joins(:details).where(PartnerDetail: { state: state })
    self
  end

  private

  attr_accessor :relation
end
