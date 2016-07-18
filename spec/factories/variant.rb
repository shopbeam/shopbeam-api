FactoryGirl.define do
  factory :variant do
    product
    sku               { Faker::Code.ean }
    color             { Faker::Commerce.color }
    colorSubstitute   { Faker::Commerce.color }
    size              { ['M', 'L', 'XXL'].sample }
    listPriceCents    { Faker::Number.between(100, 10000) }
    salePriceCents    { Faker::Number.between(100, 10000) }
    status            1
    sourceUrl         { Faker::Internet.url }
    colorFamily       { Faker::Commerce.color }
    createdAt         { Time.now }
    updatedAt         { Time.now }
  end
end
