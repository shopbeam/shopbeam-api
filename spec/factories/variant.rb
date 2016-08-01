FactoryGirl.define do
  factory :variant do
    product
    sku               { Faker::Code.ean }
    color             { Faker::Commerce.color }
    colorSubstitute   { Faker::Commerce.color }
    size              { %w(M L XXL).sample }
    listPriceCents    { Faker::Number.between(200, 300) }
    salePriceCents    { Faker::Number.between(100, 200) }
    status            1
    sourceUrl         { Faker::Internet.url }
    colorFamily       { [%w(red green blue).sample] }
    createdAt         { Time.now }
    updatedAt         { Time.now }
  end
end
