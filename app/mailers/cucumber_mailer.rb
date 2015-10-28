class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(task:, results:, retries:, status_type:)
    @results = results

    mail subject: "[order-manager:#{task}] #{to_status(status_type)}#{' [retried]' unless retries.zero?}"
  end

  private

  def to_status(status_type)
    case status_type
    when :ok      then 'OK'
    when :warning then 'WARNING'
    when :failed  then 'ACTION REQUIRED: FAILED'
    end
  end
end
