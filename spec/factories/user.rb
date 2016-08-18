FactoryGirl.define do
  factory :user do
    email     Faker::Internet.email
    password  Faker::Internet.password
    firstName Faker::Name.first_name
    lastName  Faker::Name.last_name
    status    1
    apiKey    'ae989f80-5125-f8c4-3e3a-87850b3d0f30'
    createdAt { Time.now }
    updatedAt { Time.now }
  end
end
