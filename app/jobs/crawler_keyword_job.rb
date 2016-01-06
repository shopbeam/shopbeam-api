class CrawlerKeywordJob < Batch::Job
  def run(query, provider_name)
    provider = Crawler::Provider.lookup(name: provider_name)
    result = provider.scrape_by_keyword(query)
    Crawler::RedisStorage.new(@batch_id).push(@jid, result)
  end
end
