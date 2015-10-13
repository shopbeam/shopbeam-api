require 'csv'
class CrawlersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def results
    parsed = CSV.read(params['results.csv'].tempfile)
    Crawler::Runner.hourly(parsed)
    head :accepted
  end
end
