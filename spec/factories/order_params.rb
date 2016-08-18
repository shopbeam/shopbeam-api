FactoryGirl.define do
  factory :order_params, class: Hash do |f|
    skip_create
    initialize_with { attributes }

    transient do
      # customer { create(:user) }
      variants { [create(:variant)] }
    end

    theme 'rogaine-women' # TODO: Faker::Lorem.word,
    apiKey { 'customer.api_key' } # TODO
    widgetUuid '63cf8aae-18b9-a044-25bf-2c2dfad00fea'
    shippingCents 0
    taxCents 780 # TODO: calculate tax
    orderTotalCents 6779 # TODO: calculate total
    notes ''
    appliedCommissionCents 0
    sourceUrl 'http://localhost:8000/example.html'
    shareWithPublisher true

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
          widgetUuid: widgetUuid,
          apiKey: apiKey,
          sourceUrl: sourceUrl,
          quantity: 1,
          listPriceCents: variant.list_price_cents,
          salePriceCents: variant.sale_price_cents,
          variantId: variant.id
        }
      end
    end
  end

  factory :invalid_order_params, parent: :order_params do |f|
    items nil
  end
end
