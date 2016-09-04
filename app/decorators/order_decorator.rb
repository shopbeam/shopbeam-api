class OrderDecorator < Draper::Decorator
  decorates_associations :user, :order_items
  delegate_all
  delegate :full_name, to: :user, prefix: true

  def subtotal
    Money.new(order_total_cents).format
  end

  def shipping
    shipping_cents > 0 ? Money.new(shipping_cents).format : 'FREE'
  end

  def tax
    Money.new(tax_cents).format
  end

  def total
    Money.new(total_cents).format
  end

  def partner_list
    partners.pluck(:name).to_sentence
  end

  def created_at
    object.created_at.strftime('%b %e, %Y')
  end
end
