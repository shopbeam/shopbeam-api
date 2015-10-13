class CrawlerUploadJob < Batch::Job
  def run
    Crawler::Updater.new(@batch_id).upload_results
  end

  def on_error(exception)
    CrawlerMailer.upload_error(exception, @batch_id, @jid).deliver_now
  end
end
