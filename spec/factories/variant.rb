FactoryGirl.define do
  factory :variant do
    sku       Faker::Code.ean
    createdAt Time.now
    updatedAt Time.now
  end
end
