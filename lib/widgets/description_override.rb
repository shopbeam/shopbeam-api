require 'csv'
module Widgets
  class DescriptionOverride
    def initialize(file)
      @file = file
    end

    def process
      template = Slim::Template.new("app/views/widgets/description-override/override.html.slim")
      File.open('overriden_widgets.html', 'w') do |f|
        f.puts template.render(Object.new, products: products)
      end
    end

    private
    def products
      results = []
      CSV.foreach(@file, headers: true) do |row|
        product_url = row['product url']
        size = row['Item Size or Count']
        variant = find_variant(product_url, size)
        results << {
          description: description(row),
          url: product_url,
          image_url: variant.images.first.source_url,
          variant: variant,
          brand_name: row['Brand Name'],
          name: escape(sanitize(row['Product Name'])),
          brand: variant.product.brand,
          product: variant.product,
          uid: uid(product_url)
        }
      end
      template = Slim::Template.new("app/views/widgets/description-override/product.html.slim")
      results.map do |result|
        result[:rendered] = template.render(Object.new, product: result)
        result
      end
    end

    def find_variant(product_url, size)
      variants = Variant.where(sourceUrl: product_url).all
      variant = variants.detect do |v|
        next if v.size.empty?
        v.size.match(/#{size}/i) || size.match(/#{v.size}/i) || size.delete(' ').match(/#{v.size}/i)
      end
      variant || variants.first
    end

    def description(row)
      template = Slim::Template.new("app/views/widgets/description-override/description.html.slim")
      escape template.render(Object.new,
        short_description: row['Short Description'],
        long_bullets: row['Long Bullets'],
        long_description: row['Long Descirption'],
        indications: row['Indications/Uses'],
        directions: row['Directions/Usage Instructions'],
        ingredients: row['Ingredients'],
        warnings: row['Warning and Precautions']
      )
    end

    def uid(url)
      digest = Digest::MD5.hexdigest(url)
      "#{digest[0...8]}-#{digest[8...12]}-#{digest[12...16]}-#{digest[16...20]}-#{digest[20...32]}"
    end

    def sanitize(text)
      ActionView::Base.full_sanitizer.sanitize(text)
    end

    def escape(text)
      text.gsub('®', '&reg;').gsub('™', '&trade;').gsub('©', '&copy;')
    end
  end
end
