class CrawlerMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def error(exception, batch_id, product_url)
    @batch = batch_id
    @product_url = product_url
    @exception = exception
    mail subject: "[crawler] Exception occured while scraping '#{product_url}'"
  end

  def upload_error(exception, batch_id, job_id)
    @batch = batch_id
    @job = job_id
    @exception = exception
    mail subject: "[crawler] Exception occured while uploading results for batch '#{batch_id}'"
  end
end
