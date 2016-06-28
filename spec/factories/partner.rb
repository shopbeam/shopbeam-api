FactoryGirl.define do
  factory :partner do
    name        { Faker::Company.name }
    status      1
    commission  { Faker::Number.between(1, 999) }
    linkshareId { Faker::Company.catch_phrase }
    createdAt   { Time.now }
    updatedAt   { Time.now }

    trait :with_details do
      after(:create) do |partner|
        create(:partner_detail, partner: partner, status: 1)
      end
    end
  end
end
