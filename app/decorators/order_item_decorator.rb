class OrderItemDecorator < Draper::Decorator
  delegate_all

  def image_url
    if images.present?
      "https://cloudinary-a.akamaihd.net/shopbeam/image/fetch/w_75/#{CGI.escape(images.first.source_url)}"
    end
  end

  def price
    Money.new(price_cents).format
  end

  def commission
    Money.new(commission_cents).format
  end
end
