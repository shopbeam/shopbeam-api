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
        type:            1,
        number:          '4444111111111111',
        expirationMonth: 1,
        expirationYear:  Time.now.year + 5,
        name:            Faker::Name.name,
        cvv:             '000',
        billingAddress: {
          phoneNumber: Faker::PhoneNumber.phone_number,
          address1:    Faker::Address.street_address,
          address2:    Faker::Address.street_address,
          city:        Faker::Address.city,
          state:       Faker::Address.state,
          zip:         Faker::Address.zip_code
        }
      }
    end

    user do
      {
        email:      Faker::Internet.email,
        password:   Faker::Internet.password,
        firstName:  Faker::Name.first_name,
        middleName: '',
        lastName:   Faker::Name.last_name
      }
    end

    shippingAddress do
      {
        phoneNumber: Faker::PhoneNumber.phone_number,
        address1:    Faker::Address.street_address,
        address2:    Faker::Address.street_address,
        city:        Faker::Address.city,
        state:       Faker::Address.state,
        zip:         Faker::Address.zip_code
      }
    end

    items do
      variants.map do |variant|
        {
          apiKey:         publisher.api_key,
          widgetUuid:     SecureRandom.uuid,
          sourceUrl:      Faker::Internet.url,
          quantity:       1,
          listPriceCents: variant.list_price_cents,
          salePriceCents: variant.sale_price_cents,
          variantId:      variant.id
        }
      end
    end
  end

  factory :invalid_order_params, parent: :order_params do |f|
    payment nil
  end
end
