FactoryGirl.define do
  factory :user do
    email     Faker::Internet.email
    password  Faker::Internet.password
    firstName Faker::Name.first_name
    lastName  Faker::Name.last_name
    createdAt Time.now
    updatedAt Time.now
  end
end
