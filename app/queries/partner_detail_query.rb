class PartnerDetailQuery
  def initialize(relation: PartnerDetail.all, partner_id: nil, state: nil)
    @relation = relation
    @partner_id = partner_id
    @state = state
  end

  def by_partner
    results.active
      .includes(:partner, :item_count_shipping_costs)
      .merge(Partner.active)
      .order(
        '"Partner".id,
        "PartnerDetail".state,
        "PartnerDetail".zip,
        "ItemCountShippingCost"."itemCount"'
      )
      .group_by(&:partner)
  end

  private

  attr_reader :relation, :partner_id, :state

  def results
    relation.joins(:partner).tap do |r|
      r.where!(Partner: { id: partner_id }) if partner_id
      r.where!(state: state) if state
    end
  end
end
