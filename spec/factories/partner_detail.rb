FactoryGirl.define do
  factory :partner_detail do
    partner
    state             Faker::Address.state_abbr
    zip               Faker::Address.zip
    shippingType      1
    salesTax          0
    freeShippingAbove 1000
    siteWideDiscount  0
    status            1
    createdAt         { Time.now }
    updatedAt         { Time.now }
  end
end
