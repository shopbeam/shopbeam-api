class CucumberMailer < ApplicationMailer
  default to: 'bondar.oleksandr@gmail.com'

  def completed(text, success)
    result = success ? 'success' : 'failed'
    @text = text
    mail subject: "[partner-check](#{result})"
  end
end
