FactoryGirl.define do
  factory :address do
    address1    Faker::Address.street_address
    city        Faker::Address.city
    state       Faker::Address.state
    country     Faker::Address.country_code
    zip         Faker::Address.zip_code
    phoneNumber Faker::PhoneNumber.phone_number
    createdAt   Time.now
    updatedAt   Time.now

    factory :shipping_address, class: 'ShippingAddress' do
      addressType 1
    end

    factory :billing_address, class: 'BillingAddress' do
      addressType 2
    end
  end
end
