FactoryGirl.define do
  factory :partner do
    name            { Faker::Company.name }
    status          1
    createdAt       { Time.now }
    updatedAt       { Time.now }
    commission      { Faker::Number.between(1, 999) }
    linkshareId     { Faker::Company.catch_phrase }
  end
end
