FactoryGirl.define do
  factory :order_item do
    variant
    quantity        1
    sourceUrl       Faker::Internet.url
    widgetUuid      '63cf8aae-18b9-a044-25bf-2c2dfad00fea'
    apiKey          'ae989f80-5125-f8c4-3e3a-87850b3d0f30'
    commissionCents 100
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
