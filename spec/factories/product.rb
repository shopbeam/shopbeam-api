FactoryGirl.define do
  factory :product do
    brand
    name            { Faker::Commerce.product_name }
    description     { Faker::Company.catch_phrase }
    status          1
    sku             { Faker::Code.ean }
    colorSubstitute { Faker::Commerce.color }
    sourceUrl       { Faker::Internet.url }
    minPriceCents   { Faker::Number.between(100, 200) }
    maxPriceCents   { Faker::Number.between(200, 300) }
    createdAt       { Time.now }
    updatedAt       { Time.now }

    trait :with_variants do
      after(:create) do |product|
        create(:variant, product: product, status: 1)
      end
    end

    trait :with_categories do
      after(:create) do |product|
        create(:product_category, product: product, category: create(:category, status: 1))
      end
    end

    trait :full do
      with_categories

      after(:create) do |product|
        create(:variant_image, variant: create(:variant, product: product, status: 1), status: 1)
      end
    end
  end
end
