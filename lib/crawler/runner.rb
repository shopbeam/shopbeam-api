require 'csv'
module Crawler
  class Runner
    class << self
      def hourly(python_result)
        batch = Batch.new("hourly")
        storage = Crawler::RedisStorage.new(batch.batch_id)
        storage.legacy_results = python_result
        batch.jobs do
          product_list.each do |url|
            CrawlerJob.perform_async(url)
          end
          brands_list do |brand, provider|
            CrawlerBrandJob.perform_async(brand, provider)
          end
        end.after do
          CrawlerUploadJob.perform_async
        end
      end

      private
      def product_list
        rows = CSV.read(Rails.root.join('lib', 'assets', 'crawler_realtime.csv'))
        rows.shift #skip header
        rows.map do |provider, url|
          url
        end
      end

      def brands_list
        config = YAML.load_file Rails.root.join('lib', 'assets', 'brands_list.yml')
        config['providers'].each do |provider_name, vars|
          vars['brands'].each do |brand|
            yield brand, provider_name
          end
        end
      end
    end
  end
end
