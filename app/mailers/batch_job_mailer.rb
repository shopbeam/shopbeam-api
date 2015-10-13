class BatchJobMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def error(exception, batch_id, job_id)
    @batch = batch_id
    @job = job_id
    @exception = exception
    mail subject: "[sidekiq-batch-job] Exception occured while processing batch '#{batch_id}'"
  end
end
