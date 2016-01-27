FactoryGirl.define do
  factory :product_category do
    product
    category
    status          1
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
