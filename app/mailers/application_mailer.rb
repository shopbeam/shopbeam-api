class ApplicationMailer < ActionMailer::Base
  default from: 'orders@shopbeam.com'
  layout 'mailer'
end
