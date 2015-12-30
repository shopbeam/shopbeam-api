class CrawlerBrandJob < Batch::Job
  def run(brand, provider_name)
    provider = Crawler::Provider.lookup(name: provider_name)
    if provider.can_scrape_whole_brand?
      result = provider.scrape_brand(brand)
      Crawler::RedisStorage.new(@batch_id).push(@jid, result)
    else
      products = provider.scrape_brand(brand)
      add_to_batch do
        products.each do |product_url|
          CrawlerJob.perform_async(product_url)
        end
      end
    end
  end
end
