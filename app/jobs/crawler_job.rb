class CrawlerJob < Batch::Job
  # TODO: Pass provider name as well to support lookup by name
  def run(product_url)
    @product_url = product_url
    provider = Crawler::Provider.lookup(url: product_url)
    result = provider.new(product_url).scrape
    Crawler::RedisStorage.new(@batch_id).push(@jid, result)
  end

  def add_newrelic_params
    ::NewRelic::Agent.add_custom_attributes(batch_id: @batch_id, jid: @jid, product_url: @product_url)
  end
end
