FactoryGirl.define do
  factory :category do
    name            { Faker::Commerce.product_name }
    status          1
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
