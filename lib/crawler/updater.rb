module Crawler
  class Updater
    def initialize(batch_id)
      @batch_id = batch_id
    end

    def upload_results
      result = merge_results
      path = "singleproducts/results-#{Time.now.to_i}.csv"
      Net::SFTP.start(ENV['SFTP_HOST'], ENV['SFTP_USER'], password: ENV['SFTP_PASSWORD']) do |sftp|
        sftp.file.open(path, "w") do |f|
          f.puts result.force_encoding('binary')
        end
      end

      heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
      heroku.post_ps(ENV['HEROKU_APP'], "EXTRA_LOGGING=true node server/import/ftp.js ftp://#{ENV['SFTP_USER']}@#{ENV['SFTP_HOST']}/#{path} -singleproduct")
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
            csv << Crawler::SMF.new(r.symbolize_keys).to_a
          end
        end
      end
    end
  end
end
