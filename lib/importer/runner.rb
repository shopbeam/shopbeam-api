require 'csv'
module Importer
  class Runner
    class << self
      def from_csv(csv)
        products = CSV.parse(csv)
        products.shift
        products.map! do |product_attrs|
          transform(product_attrs)
        end
        Importer::Products.new(products).process
        Rails.logger.info "import finished"
      end

      private
      def transform(attrs)
        result = {}
        Crawler::SMF_FIELDS.each_with_index do |field, index|
          result[field] = attrs[index]
        end
        Crawler::SMF.new(result)
      end
    end
  end
end
