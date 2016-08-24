FactoryGirl.define do
  factory :order do
    payment
    shippingCents          100
    taxCents               100
    orderTotalCents        100
    appliedCommissionCents 100
    status                 9
    shareWithPublisher     true
    apiKey                 { SecureRandom.uuid }
    createdAt              { Time.now }
    updatedAt              { Time.now }

    factory :full_order do
      user
      shipping_address
      billing_address
    end
  end
end
