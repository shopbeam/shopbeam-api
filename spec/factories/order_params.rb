FactoryGirl.define do
  factory :order_params, class: Hash do |f|
    skip_create
    initialize_with { attributes }

    transient do
      publisher { create(:user) }
      variants { [create(:variant)] }
    end

    theme                  { Faker::Lorem.word }
    apiKey                 { SecureRandom.uuid }
    widgetUuid             { SecureRandom.uuid }

    orderTotalCents do
      items.inject(0) { |total, item| total + (item[:salePriceCents] || item[:listPriceCents]) * item[:quantity] }
    end

    taxCents               { orderTotalCents * 0.875 }
    shippingCents          0
    appliedCommissionCents 0
    notes                  { Faker::Lorem.sentence }
    sourceUrl              { Faker::Internet.url }
    shareWithPublisher     true

    payment do
      {
        type: 1,
        number: '4444111111111111',
        expirationMonth: 2,
        expirationYear: 2018,
        name: 'Bryan White',
        cvv: '123',
        billingAddress: {
          phoneNumber: '1234567890',
          address1: '9450 SW Gemini Dr.',
          address2: '#42146',
          city: 'Beaverton',
          state: 'MB',
          zip: 'a1a 1a1'
        }
      }
    end

    user do
      {
        email: 'bryan@shopbeam.com',
        password: 'Shopbeam123',
        firstName: 'Bryan',
        middleName: '',
        lastName: 'White'
      }
    end

    shippingAddress do
      {
        phoneNumber: '1234567890',
        address1: '9450 SW Gemini Dr.',
        address2: '#42146',
        city: 'Beaverton',
        state: 'MB',
        zip: 'a1a 1a1'
      }
    end

    items do
      variants.map do |variant|
        {
          apiKey: publisher.api_key,
          widgetUuid: SecureRandom.uuid,
          sourceUrl: Faker::Internet.url,
          quantity: 1,
          listPriceCents: variant.list_price_cents,
          salePriceCents: variant.sale_price_cents,
          variantId: variant.id
        }
      end
    end
  end

  factory :invalid_order_params, parent: :order_params do |f|
    payment nil
  end
end
