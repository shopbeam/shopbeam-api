FactoryGirl.define do
  factory :proxy_user do
    user
    partner_type 'Checkout::Partners::WellCa'
  end
end
