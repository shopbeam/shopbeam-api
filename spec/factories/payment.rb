FactoryGirl.define do
  factory :payment do
    type            1
    salt            { SecureRandom.base64 }
    number          { Encryptor.encrypt('4111111111111111', salt)[:value] }
    expirationMonth { Encryptor.encrypt('5', salt)[:value] }
    expirationYear  { Encryptor.encrypt("#{Time.now.year + 5}", salt)[:value] }
    name            { Encryptor.encrypt(Faker::Name.name, salt)[:value] }
    cvv             { Encryptor.encrypt('000', salt)[:value] }
    createdAt       Time.now
    updatedAt       Time.now
  end
end
