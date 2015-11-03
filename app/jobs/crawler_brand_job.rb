class CrawlerBrandJob < Batch::Job
  def run(brand, provider_name)
    provider = Crawler::Provider.lookup(name: provider_name)
    products = provider.scrape_brand(brand)
    add_to_batch do
      products.each do |product_url|
        CrawlerJob.perform_async(product_url)
      end
    end
  end
end
