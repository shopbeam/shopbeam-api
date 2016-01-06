require 'open-uri'

module Crawler
  module Providers
    class TargetCom < Crawler::Provider
      BASE_URL = "http://www.target.com"
      API_URL = "http://tws.target.com/searchservice/item/brand_results/v2/by_brand"
      KEYWORD_URL = "http://tws.target.com/searchservice/item/search_results/v2/by_keyword"
      PAGINATOR = 100

      class << self
        def get_json(url)
          JSON.parse(URI.parse(url).open.read)
        end

        def scrape_brand(brand)
          process_all_pages(API_URL, keyword: "guest_mfg_brand=#{brand}")
        end

        def scrape_by_keyword(opts)
          process_all_pages(KEYWORD_URL, opts)
        end

        def can_scrape_whole_brand?
          true
        end

        private
        def process_all_pages(url, opts)
          offset, results = 0, []

          begin
            result = []
            limit = opts['limit'] || PAGINATOR
            page = get_json("#{url}?pageCount=#{limit}&offset=#{offset}&response_group=Items%2CVariationSummary&#{opts['keyword']}")
            page['searchResponse']['items']['Item'].each do |product|
              result += self.new(product).scrape
            end
            results += result
            offset += PAGINATOR
          end while result.any? && !opts['limit']

          results
        end
      end

      def initialize(product)
        @product = product
      end

      def scrape
        result = []
        return result if sold_out?
        variations do |size, color, image, price, name|
          params = {
            name: name,
            brand: brand,
            'original-brand': brand.upcase,
            partner: "Target.com",
            description: description,
            'original-category': ['New'],
            category: '',
            color: color,
            size: size,
            'list-price': price,
            'sale-price': nil,
            'source-url': details_url,
            'image-url1': image.split('?').first
          }
          result << SMF.new(params)
        end
        result
      end

      private
      def default_name
        @product['title']
      end

      def brand
        @product['brand']
      end

      def description
        desc = @product['itemAttributes']['productDescription']
        desc.empty? ? default_name : desc
      end

      def details_url
        "#{BASE_URL}/#{@product['productDetailPageURL']}"
      end

      def sold_out?
        @product['inventorySummary']['availabilityInventoryCode'].to_i != 0
      end

      def default_price
        price = @product['priceSummary']['listPrice']['amount']
        price = @product['priceSummary']['offerPrice']['amount'] if price.empty?
        price.split("-").first
      end

      def default_color
        if summary = @product['variationSummary']
          key, with_color = summary.detect { |k, s| s['definedAttributes'].try(:[], 'color') }
          with_color ? with_color['definedAttributes']['color'] : ""
        else
          ""
        end
      end

      def variations
        if summary = @product['variationSummary']
          summary.each do |k, variation|
            attrs = variation['definedAttributes'] || {}
            size = attrs['size'] || ''
            color = attrs['color'] || ''
            price = variation['offerPrice'] || variation['listPrice']
            price = default_price if price.empty?
            name = variation['title']

            yield size, color, variation['imagePath'], price, name
          end
        else
          yield '', '', default_image, default_price, default_name
        end
      end

      def default_image
        img = @product['images']['image'].detect { |obj| obj['type'] == 'internal' }
        img['url']
      end
    end
  end
end
