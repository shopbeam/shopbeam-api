FactoryGirl.define do
  factory :account do
    transient do
      encrypted_password Encryptor.encrypt(Faker::Internet.password)
    end

    first_name    Faker::Name.first_name
    last_name     Faker::Name.last_name
    partner_type  'FakePartner'
    email         Faker::Internet.email
    password      { encrypted_password[:value] }
    password_salt { encrypted_password[:salt] }
    created_at    { Time.now }
    updated_at    { Time.now }
  end
end
