FactoryGirl.define do
  factory :order do
    payment
    shippingCents          100
    taxCents               100
    orderTotalCents        100
    appliedCommissionCents 100
    status                 9
    shareWithPublisher     true
    apiKey                 'ae989f80-5125-f8c4-3e3a-87850b3d0f30'
    createdAt              Time.now
    updatedAt              Time.now
  end
end
