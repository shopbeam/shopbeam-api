FactoryGirl.define do
  factory :product do
    brand
    name            { Faker::Commerce.product_name }
    description     { Faker::Company.catch_phrase }
    status          1
    sku             { Faker::Code.ean }
    colorSubstitute { Faker::Commerce.color }
    sourceUrl       { Faker::Internet.url }
    salePercent     { Faker::Number.between(1, 100) }
    minPriceCents   { Faker::Number.between(100, 10000) }
    maxPriceCents   { Faker::Number.between(100, 10000) }
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
