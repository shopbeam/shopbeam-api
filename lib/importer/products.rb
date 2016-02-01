module Importer
  class Products
    attr_accessor :data, :normalized

    def initialize(data)
      @data = data
      @normalized = {}
      @invalid_count = 0
    end

    def process
      normalize
      start_time = timestamp
      normalized.each do |parent_sku, variants|
        valid = validate_variants(variants)
        unless valid.empty?
          partner = create_partner(valid.first.partner)
          brand = create_brand(valid.first.brand, partner.id)
          product = create_product(variant: valid.first, sku: parent_sku, brand: brand, partner: partner)
          categories = create_categories(product, valid.first)
          create_product_categories(product, categories)
          valid.each { |variant| create_variant(variant, product) }
          Rails.logger.info "done with product #{product.id}"
        end
      end
      Invalidator.by_time(start_time)
      Rails.logger.info "Ivalid variants count: #{@invalid_count} out of #{data.count}"
    end

    private
    def normalize
      data.each do |product|
        add_product product
      end
    end

    def add_product(product)
      normalized[product.parent_sku] ||= []
      normalized[product.parent_sku] << product
    end

    def create_partner(name)
      partner = Partner.create_with(default_opts.merge(commission: 0))
                       .find_or_create_by(name: name)
      partner.update!(status: 1, validatedAt: timestamp)
      partner
    end

    def create_brand(name, partner_id)
      brand = Brand.create_with(default_opts)
                   .find_or_create_by(name: name, PartnerId: partner_id)
      brand.update!(status: 1, validatedAt: timestamp)
      brand
    end

    def create_product(variant:, sku:, brand:, partner:)
      opts = {
        name: variant.name,
        description: variant.description,
        status: 1,
        colorSubstitute: variant.color_substitute,
        sourceUrl: variant.source_url,
        validatedAt: timestamp,
        updatedAt: Time.now,
        searchText: [brand.name, variant.name, partner.name].join(' ')
      }
      product = Product.create_with(opts.merge(createdAt: Time.now))
                       .find_or_create_by(sku: sku, BrandId: brand.id)
      product.update!(opts)
      product
    end

    def create_categories(product, variant)
      result = []
      categories = variant.original_category.split(':').map(&:strip)
      return result if categories.empty?
      # TODO
      # actually all this category structure is pretty messed up
      # change it after remove of spock
      # start with changing db constraint to include parentId
      result << parent = Category.create_with(default_opts.merge(parentId: nil))
                                 .find_or_create_by(name: categories.first)
      categories[1..-1].each do |category|
        parent = Category.create_with(default_opts.merge(parentId: parent.id))
                         .find_or_create_by(name: categories.first)
        result << parent
      end
      result.each do |category|
        category.update!(status: 1, validatedAt: timestamp)
      end
      result
    end

    def create_product_categories(product, categories)
      categories.each do |category|
        record = ProductCategory.create_with(default_opts)
                                .find_or_create_by(CategoryId: category.id, ProductId: product.id)
        record.update!(status: 1, validatedAt: timestamp)
      end
    end

    def create_variant(variant, product)
      opts = {
        color: variant.color,
        colorFamily: variant.color_family.split('|@|'),
        colorSubstitute: variant.color_substitute,
        size: variant.size,
        listPriceCents: variant.list_price.empty? ? nil : Monetize.parse(variant.list_price).cents,
        salePriceCents: variant.sale_price.empty? ? nil : Monetize.parse(variant.sale_price).cents,
        partnerData: variant.partner_data,
        status: 1,
        validatedAt: timestamp,
        sourceUrl: variant.source_url,
        updatedAt: Time.now
      }
      record = Variant.create_with(opts.merge(createdAt: Time.now))
                      .find_or_create_by(sku: variant.sku, ProductId: product.id)
      record.update!(opts)
      create_images(variant, record.id)
      record
    end

    def create_images(variant, variant_id)
      (1..7).map do |index|
        url = variant.send("image_url#{index}")
        unless url.empty?
          opts = {
            url: url,
            sourceUrl: url,
            status: 1,
            validatedAt: timestamp,
            updatedAt: Time.now,
            sortOrder: index
          }
          image = VariantImage.create_with(opts.merge(createdAt: Time.now))
                              .find_or_create_by(VariantId: variant_id, url: url)
          image.update!(opts)
          image
        end
      end
    end

    def default_opts
      {status: 1, createdAt: Time.now, updatedAt: Time.now, validatedAt: timestamp}
    end

    def validate_variants(variants)
      valid = variants.select do |variant|
        variant.brand.present? &&
        variant.name.present? &&
        variant.original_category.present? &&
        variant.description.present? &&
        variant.parent_sku.present? &&
        variant.image_url1.present?
      end
      @invalid_count += (variants.count - valid.count)
      valid
    end

    def timestamp
      Time.now.to_i * 1000
    end
  end
end
