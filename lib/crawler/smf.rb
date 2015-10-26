require 'crawler'
module Crawler
  class SMF < SmartStruct.keyword(*SMF_FIELDS)
    def to_a
      SMF_FIELDS.map {|field| self[field].nil? ? '' : self[field] }
    end

    def format
      format_brand
      format_color
      format_name
      format_prices
      format_categories
      format_size
      generate_sku
      self
    end

    private
    def format_brand
      self.original_brand = brand
      self.original_brand.upcase! if brand == 'Lacoste'
      self.brand = capitalize brand.downcase
    end

    def format_color
      self.color_family, self.color = ColorMap.format(color)
    end

    def format_name
      self.name = name.sub(brand, '').sub(color, '').gsub(/^\./, '').strip
    end

    def format_prices
      self.list_price = format_price(list_price)
      self.sale_price = format_price(sale_price)
    end

    def format_price(price)
      return unless price
      parsed = Monetize.parse(price)
      parsed.format(symbol: false)
    end

    def format_categories
      self.original_category = original_category.join(': ')
    end

    def format_size
      self.size = capitalize size
    end

    def capitalize(text)
      return unless text
      text.split(" ").map(&:capitalize).join(" ")
    end

    def generate_sku
      self.sku = uid(name, brand, color, size, 'child')
      self.parent_sku = uid(name, brand)
    end

    def uid(*args)
      ascii = args.join.encode(Encoding.find('ASCII'), undef: :replace, invalid: :replace, replace: '')
      Digest::MD5.hexdigest(ascii)[0...16]
    end
  end
end
