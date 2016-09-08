FactoryGirl.define do
  factory :order_item do
    variant
    quantity        1
    sourceUrl       Faker::Internet.url
    widgetUuid      { SecureRandom.uuid }
    apiKey          { SecureRandom.uuid }
    commissionCents 100
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
