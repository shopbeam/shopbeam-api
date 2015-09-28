class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def partners_completed(text, status_type)
    @text = text

    mail subject: "[order-manager:partners] #{to_status(status_type)}" do |format|
      format.text { render 'completed' }
    end
  end

  def widgets_completed(text, status_type)
    @text = text

    mail subject: "[order-manager:widgets] #{to_status(status_type)}" do |format|
      format.text { render 'completed' }
    end
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
