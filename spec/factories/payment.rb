FactoryGirl.define do
  factory :payment do
    type            1
    number          '4111111111111111'
    expirationMonth 1
    expirationYear  { Time.now.year + 5 }
    name            { Faker::Name.name }
    cvv             '000'
    createdAt       { Time.now }
    updatedAt       { Time.now }
  end
end
