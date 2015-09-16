class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(text, success)
    status = success ? 'OK' : 'FAIL'
    @text = text

    mail subject: "[order-manager:tests] #{status}"
  end
end
