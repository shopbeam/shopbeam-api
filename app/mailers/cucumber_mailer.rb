class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def partners_completed(text, success)
    @text = text
    mail subject: "[order-manager:partners] #{status(success)}"
  end

  def widgets_completed(text, success)
    @text = text
    mail subject: "[order-manager:widgets] #{status(success)}"
  end

  def status(success)
    success ? 'OK' : 'ACTION REQUIRED: FAILED'
  end
end
