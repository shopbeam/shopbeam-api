class ApplicationMailer < ActionMailer::Base
  default from: 'orders@shopbeam.com'
  layout 'mailer'

  protected

  def prepend_theme_path(theme)
    prepend_view_path Rails.root.join('app', 'views', 'themes', theme)
  end
end
