module Crawler
  class Updater
    EXTERNAL_RESULTS_FILES = ['well_ca']

    def initialize(batch_id)
      @batch_id = batch_id
    end

    def upload_results
      Importer::Runner.from_csv(merge_results)
    end

    private
    def merge_results
      storage = Crawler::RedisStorage.new(@batch_id)
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

    def store_legacy_results(results)
      file = CSV.generate do |csv|
        results.each do |row|
          csv << row
        end
      end
      Aws::S3::Client.new.put_object(bucket: 'sb-crawls', key: "python_legacy.csv", body: file.force_encoding('binary'))
    end

    def external_results
      s3 = Aws::S3::Client.new
      results = []
      EXTERNAL_RESULTS_FILES.each do |file|
        results += JSON.parse(s3.get_object(bucket: 'sb-scrapinghub-results', key: "#{file}.json").body.read)
      end
      results
    end

    def legacy_results
      s3 = Aws::S3::Client.new
      CSV.parse(s3.get_object(bucket: 'sb-crawls', key: "python_legacy.csv").body.read)
    end
  end
end
