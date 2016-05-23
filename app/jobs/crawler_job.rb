class CrawlerJob < Batch::Job
  def run(product_hash)
    @product_url = product_hash[:product_url]
    provider_name = product_hash[:provider_name]
    provider = Crawler::Provider.lookup(name: provider_name)
    result = provider.new(@product_url).scrape
    Crawler::RedisStorage.new(@batch_id).push(@jid, result)
  end

  def add_newrelic_params
    ::NewRelic::Agent.add_custom_attributes(batch_id: @batch_id, jid: @jid, product_url: @product_url)
  end
end
