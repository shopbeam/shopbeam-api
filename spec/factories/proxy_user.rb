FactoryGirl.define do
  factory :proxy_user do
    user
    provider_type 'Checkout::Partners::WellCa'
  end
end
