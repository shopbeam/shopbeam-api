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
        params = {
          partner: partner,
          brand: brand,
          name: name,
          color: color,
          size: size,
          description: description,
          category: '',
          'original-category': original_category,
          'list-price': list_price,
          'sale-price': sale_price,
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
        @size ||= @page.css(".product_info_header .product_text_product_subtitle span[style='display: inline-block']").first.try(:text) || ""
      end

      def description
        @description ||= @page.css(".product_text.product_text_product_description").inner_html
      end

      def original_category
        @original_category ||= begin
          breadcrumbs = @page.css(".bread_crumb_container a")
          breadcrumbs.shift
          breadcrumbs.map {|b| strip_tabs b.text }
        end
      end

      def parse_prices
        return if defined? @list_price
        @list_price = @page.css(".product_price_container .product_text.product_text_product_subtitle.product_text_sale_price").try(:text)
        @sale_price = @page.css(".product_price_container .product_text_price").try(:text)
        if @list_price.empty?
          @list_price = @sale_price
          @sale_price = nil
        end
      end

      def list_price
        parse_prices
        @list_price
      end

      def sale_price
        parse_prices
        @sale_price
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
