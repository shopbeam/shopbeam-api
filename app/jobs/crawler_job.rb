class CrawlerJob < Batch::Job
  def run(product_url)
    @product_url = product_url
    provider = Crawler::Provider.lookup(url: product_url)
    result = provider.new(product_url).scrape
    Crawler::RedisStorage.new(@batch_id).push(@jid, result)
  end

  def on_error(exception)
    CrawlerMailer.error(exception, @batch_id, @product_url).deliver_now
  end
end
