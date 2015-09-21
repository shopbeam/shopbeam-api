class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(text, success)
    @text = text

    mail subject: "[order-manager:tests] #{success ? 'OK' : 'ACTION REQUIRED: FAILED'}"
  end
end
