desc 'Create product, brand, partner, variant and image for Advertising Week pass'
task create_aw_pass: :environment do
  ActiveRecord::Base.transaction do
    partner = Partner.create_with(
      status: 1,
      commission: 0,
      createdAt: Time.now,
      updatedAt: Time.now
    ).find_or_create_by!(name: 'Advertising Week')

    brand = Brand.create_with(
      status: 1,
      partner: partner,
      createdAt: Time.now,
      updatedAt: Time.now
    ).find_or_create_by!(name: 'Advertising Week')

    product = Product.create_with(
      status: 1,
      demo: true,
      brand: brand,
      description: '',
      searchText: '',
      sku: :fake,
      createdAt: Time.now,
      updatedAt: Time.now
    ).find_or_create_by!(name: 'Delegate Pass: 18-22 April 2016 London')

    variant = Variant.create_with(
      status: 1,
      sourceUrl: 'https://advertisingweek.eu/register/',
      sku: :fake,
      listPriceCents: 44900,
      createdAt: Time.now,
      updatedAt: Time.now
    ).find_or_create_by!(product: product, size: 'Delegate')

    image = VariantImage.create_with(
      status: 1,
      url: 'https://staging.shopbeam.com/alt-images/advertisingweek/delegate-pass.svg',
      sourceUrl: 'https://staging.shopbeam.com/alt-images/advertisingweek/delegate-pass.svg',
      sortOrder: 1,
      validatedAt: Time.now.to_i * 1000,
      createdAt: Time.now,
      updatedAt: Time.now
    ).find_or_create_by!(variant: variant)
  end
end
