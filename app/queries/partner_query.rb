class PartnerQuery
  def initialize(relation: Partner.all, partner_id: nil, state: nil)
    @relation = relation
    @partner_id = partner_id
    @state = state
  end

  def active
    results.eager_load(details: :active_shipping_items)
      .merge(Partner.active)
      .merge(PartnerDetail.active)
      .order('
        "Partner".id,
        "PartnerDetail".state,
        "PartnerDetail".zip,
        "ItemCountShippingCost"."itemCount"
      ')
  end

  private

  attr_reader :relation, :partner_id, :state

  def results
    relation.joins(:details).tap do |r|
      r.where!(id: partner_id) if partner_id
      r.where!(PartnerDetail: { state: state }) if state
    end
  end
end
