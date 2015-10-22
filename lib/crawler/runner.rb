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
    end
  end
end
