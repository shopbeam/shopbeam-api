FactoryGirl.define do
  factory :item_count_shipping_cost, aliases: [:shipping_item] do
    partner_detail
    itemCount     1
    shippingPrice 100
    status        1
    createdAt     { Time.now }
    updatedAt     { Time.now }
  end
end
