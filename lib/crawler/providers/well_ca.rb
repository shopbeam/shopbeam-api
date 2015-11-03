require 'open-uri'

module Crawler
  module Providers
    class WellCa < Crawler::Provider
      class << self
        def scrape_brand(brand)
          result, page = [], 1

          loop do
            products = scrape_brand_page(brand, page)
            result += products
            page += 1
            break unless products.any?
          end
          result
        end

        def scrape_brand_page(brand, page_number)
          page = get("https://well.ca/brand/#{brand}.html?page=#{page_number}")
          page.css(".product_grid_link").map do |product_link|
            product_link['href']
          end
        end
      end

      def scrape
        return [] if sold_out?
        color_family, formatted_color = ColorMap.format(color)
        formatted_name = format_name(name, brand, formatted_color)
        formatted_brand = capitalize brand.downcase
        params = {
          partner: partner,
          brand: formatted_brand,
          'original-brand': brand,
          name: formatted_name,
          color: formatted_color,
          'color-family': color_family,
          size: size,
          description: description,
          category: '',
          'original-category': format_categories(original_category),
          'list-price': prices[:list],
          'sale-price': prices[:sale],
          sku: uid(formatted_name, formatted_brand, formatted_color, size, 'child'),
          'parent-sku': uid(formatted_name, formatted_brand),
          'source-url': @url
        }
        images.each_with_index do |img, index|
          params[:"image-url#{index+1}"] = img
        end
        [SMF.new(params)]
      end

      private
      def partner
        "Well.ca"
      end

      def sold_out?
        @page.css(".unavailable_sprite_container").any?
      end

      def brand
        @brand ||= begin
          link = @page.css("a[href*='brand']:contains('View all')")
          link.text.match(/view all (.+) products/i)[1]
        end
      end

      def name
        @name ||= @page.css(".product_text.product_text_product_name").text
      end

      def color
        @color ||= @page.css(".product_info_header .product_text_product_subtitle span[style*='color:']").first.try(:text) || ""
      end

      def size
        @size ||= capitalize @page.css(".product_info_header .product_text_product_subtitle span[style='display: inline-block']").first.try(:text) || ""
      end

      def description
        @description ||= @page.css(".product_text.product_text_product_description").inner_html
      end

      def original_category
        @original_category ||= begin
          breadcrumbs = @page.css(".bread_crumb_container a")
          breadcrumbs.shift
          breadcrumbs.map {|b| b.text }
        end
      end

      def prices
        @prices ||= begin
          list_price = @page.css(".product_price_container .product_text.product_text_product_subtitle.product_text_sale_price").try(:text)
          sale_price = @page.css(".product_price_container .product_text_price").try(:text)
          if list_price.empty?
            list_price = sale_price
            sale_price = nil
          end
          format_prices(list: list_price, sale: sale_price)
        end
      end

      def images
        @images ||= begin
          images = [@page.css(".product_main_image img").first['src']]
          @page.css(".product_text.product_text_product_description img").each do |i|
            images << i['src']
          end
          images
        end
      end
    end
  end
end
