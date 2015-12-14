module FeatureHelper
  def build_session(address)
    shipping_address = build_stubbed(:shipping_address, address)
    billing_address = build_stubbed(:billing_address, address)
    order = build_stubbed(:full_order, shipping_address: shipping_address, billing_address: billing_address)

    Checkout::Session.new(order)
  end
end
