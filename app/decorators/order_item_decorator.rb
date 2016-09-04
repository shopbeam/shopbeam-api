class OrderItemDecorator < Draper::Decorator
  delegate_all

  def image_url
    images.first.source_url if images.present?
  end

  def price
    Money.new(price_cents).format
  end
end
