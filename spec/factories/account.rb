FactoryGirl.define do
  factory :account do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    partner_type  'FakePartner'
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }
    created_at    { Time.now }
    updated_at    { Time.now }
  end
end
