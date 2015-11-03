FactoryGirl.define do
  factory :proxy_user do
    user
    partner_type 'FakePartner'
  end
end
