FactoryGirl.define do
  factory :payment do
    name            Faker::Name.name
    number          'MUw5cVB6V3NsVUZINm9LbW0xSnZMQlFOM2ErR29hUGlMNitqR3IySndZTT0tLUJRMjl6NVJzRFpzN3BzNlduZlpCOVE9PQ==--f25160b33b4dfcd1eb27ca1670c1b38fdf14652b'
    numberSalt      'nCqdjSXdEMcXPPBoqIi5zg=='
    cvv             '000'
    expirationMonth 5
    expirationYear  Time.now.year + 5
    type            1
    createdAt       Time.now
    updatedAt       Time.now
  end
end
