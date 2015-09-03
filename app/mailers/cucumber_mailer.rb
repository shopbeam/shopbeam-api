class CucumberMailer < ApplicationMailer
  default to: 'tech@shopbeam.com'

  def completed(text, success)
    result = success ? 'success' : 'failed'
    @text = text
    mail subject: "[partner-check](#{result})"
  end
end
