class CrawlerJob < Batch::Job
  def run(url:, name:)
    @product_url = url
    provider = Crawler::Provider.lookup(name: name)
    result = provider.new(product_hash).scrape
    Crawler::RedisStorage.new(@batch_id).push(@jid, result)
  end

  def add_newrelic_params
    ::NewRelic::Agent.add_custom_attributes(batch_id: @batch_id, jid: @jid, product_url: @product_url)
  end
end
