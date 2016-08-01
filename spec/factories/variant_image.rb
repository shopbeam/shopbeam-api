FactoryGirl.define do
  factory :variant_image do
    variant
    url       { Faker::Internet.url }
    sourceUrl { Faker::Internet.url }
    status    1
    createdAt { Time.now }
    updatedAt { Time.now }
  end
end
