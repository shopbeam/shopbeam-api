FactoryGirl.define do
  factory :order do
    shippingCents          123
    taxCents               123
    orderTotalCents        123
    appliedCommissionCents 123
    status                 9
    shareWithPublisher     true
    apiKey                 'a12b3-c45d6-e78f9'
    createdAt              Time.now
    updatedAt              Time.now
  end
end
