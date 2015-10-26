require 'open-uri'

module Crawler
  module Providers
    class LacosteComUs < Crawler::Provider
      def scrape
        result = []
        variations do |color, images, prices, size|
          params = {  name: name,
                      brand: brand,
                      'original-brand': brand.upcase,
                      partner: brand.capitalize,
                      description: description,
                      'original-category': original_category,
                      category: '',
                      color: color,
                      size: size,
                      'list-price': prices[:list],
                      'sale-price': prices[:sale],
                      'source-url': @url}
          images.each_with_index do |img, index|
            params[:"image-url#{index+1}"] = img
          end
          result << SMF.new(params)
        end
        result
      end

      private
      def name
        @name ||= @page.css(".sku-product-name span[itemprop='name']").text
      end

      def brand
        "Lacoste"
      end

      def description
        @description ||= strip_tabs @page.css("div[itemprop='description']").inner_html
      end

      def original_category
        @original_category ||= begin
          breadcrumbs = @page.css("ol.breadcrumb a")[1..-1]
          result = if breadcrumbs
            breadcrumbs.map do |breadcrumb|
              strip_tabs breadcrumb.child.text
            end
          else
            ["New"]
          end
        end
      end

      def colors
        @colors ||= begin
          colors = []
          color_urls = @page.css(".swatches.color .product-colors li a").map { |a| a['data-href'] }
          if color_urls.empty?
            images = @page.css("[property='og:image']")
            color = @page.css("input[name='selectedColor']")
            colors << { color: color, images: images, page: @page }
          else
            color_urls.each do |color_url|
              color_page = self.class.get(color_url)
              images = color_page.css("[itemprop='image'] [itemprop='image']")
              color = color_page.css("input[name='selectedColor']")
              colors << { color: color, images: images, page: color_page }
            end
          end
          colors
        end
      end

      def variations
        colors.each do |color|
          next unless available?(color[:page])
          parse_prices!(color)
          parse_sizes!(color)
          color[:sizes].each do |size|
            yield format_color(color[:color]),
                  format_images(color[:images]),
                  color[:prices],
                  size
          end
        end
      end

      def available?(page)
        has_color = page.css("#haveColorAvailable").first
        has_color && (has_color['value'] == "true")
      end

      def parse_prices!(color)
        return if color[:prices]
        color[:prices] = {}

        list_price = color[:page].css(".price-standard").first
        sale_price = color[:page].css(".price-sales").first
        unless sale_price
          sale_price = color[:page].css(".price-sales .product-after-sale").first
        end
        unless list_price
          list_price = sale_price
          sale_price = nil
        end

        color[:prices][:list] = list_price.try(:text)
        color[:prices][:sale] = sale_price.try(:text)
      end

      def parse_sizes!(color)
        return if color[:sizes]
        color[:sizes] = []

        sizes = color[:page].css("select.product-sizes.sku-product-sizes option")
        if sizes.any?
          sizes.shift
          sizes.each do |size|
            next if size['disabled']
            color[:sizes] << format_size(size)
          end
        else
          color[:sizes] << ''
        end
      end

      def format_size(size)
        size.text.strip.downcase
      end

      def format_color(color)
        color.first['value'].gsub(/\d/, '').downcase.capitalize
      end

      def format_images(images)
        images.map do |img|
          url = img['content'] || img['data-src']
          ERB::Util.html_escape(url)
        end
      end
    end
  end
end
