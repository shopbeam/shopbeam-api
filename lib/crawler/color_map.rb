require 'csv'
module Crawler
  class ColorMap
    SEPARATORS = ['/', '-', ',', ' with ', '&amp;', '&', ' and ', ' ']

    class << self
      def format(color)
        family = get_family(color)
        name = capitalize(color).sub('With', 'with').sub('And', 'and').gsub(/[0-9]*/, '').strip()
        [family.uniq.compact.join('|@|'), name]
      end

      private
      def get_family(color_name)
        family = color_family(color_name)
        if family
          family
        elsif separator = try_split(color_name)
          colors = color_name.split(separator)
          family = colors.map { |c| get_family c }
          family.flatten
        else
          []
        end
      end

      def color_family(color)
        mappings[color.downcase]
      end

      def mappings
        return @mappings if defined? @mappings
        colors = CSV.read("lib/assets/colors.csv")
        colors.shift # skip header
        result = {}
        colors.each do |color|
          result[color.shift] = color.compact
        end
        @mappings = result
      end

      def try_split(text)
        SEPARATORS.detect do |sep|
          text.split(sep).count > 1
        end
      end

      def capitalize(text)
        text.split(" ").map(&:capitalize).join(" ")
      end
    end
  end
end
