FactoryGirl.define do
  factory :brand do
    name            { Faker::Company.name }
    status          1
    createdAt       { Time.now }
    updatedAt       { Time.now }
    partner
  end
end
