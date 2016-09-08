FactoryGirl.define do
  factory :brand do
    partner
    name      { Faker::Company.name }
    status    1
    createdAt { Time.now }
    updatedAt { Time.now }
  end
end
