require 'sidekiq/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == Rails.application.secrets.admin_monitor_password
  end if Rails.env.production?

  mount Sidekiq::Web, at: '/admin/sidekiq'

  # Spock route to place incoming orders
  post '/orders/:id/fill', to: 'orders#fill'

  # Mailgun route to handle incoming emails
  post '/orders/mail', to: 'orders#mail'

  get '/unsubscribe/:signature', to: 'proxy_users#unsubscribe', as: 'unsubscribe'

  # Python crawlers upload results here
  post '/crawlers/results', to: 'crawlers#results'
end
