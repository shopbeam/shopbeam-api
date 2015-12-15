module Crawler
  class Updater
    EXTERNAL_RESULTS_FILES = ['well_ca']

    def initialize(batch_id)
      @batch_id = batch_id
    end

    def upload_results
      result = merge_results
      Aws::S3::Client.new.put_object(bucket: 'sb-crawls', "#{ENV['STAGE_NAME']}.csv", body: result.force_encoding('binary'))

      heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
      heroku.post_ps(ENV['HEROKU_APP'], "EXTRA_LOGGING=true node server/import/s3.js #{ENV['STAGE_NAME']}")
    end

    private
    def merge_results
      storage = Crawler::RedisStorage.new(@batch_id)
      legacy_results = JSON.parse(storage.legacy_results)

      CSV.generate do |csv|
        legacy_results.each do |row|
          csv << row
        end
        storage.all.each do |job_id, results|
          results.each do |r|
            csv << Crawler::SMF.new(r.symbolize_keys).format.to_a
          end
        end
        external_results.each do |result|
          csv << Crawler::SMF.new(result.symbolize_keys).format.to_a
        end
      end
    end

    def external_results
      s3 = Aws::S3::Client.new
      results = []
      EXTERNAL_RESULTS_FILES.each do |file|
        results += JSON.parse(s3.get_object(bucket: 'sb-scrapinghub-results', key: "#{file}.json").body.read)
      end
      results
    end
  end
end
