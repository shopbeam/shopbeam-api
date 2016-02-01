require 'sidekiq/web'

Rails.application.routes.draw do
  mount API::Root, at: '/'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == Rails.application.secrets.admin_monitor_password
  end if Rails.env.production?

  mount Sidekiq::Web, at: '/admin/sidekiq'

  # Spock route to place incoming orders
  post '/orders/:id/fill', to: 'orders#fill'

  # Mailgun route to handle incoming emails
  post '/orders/mail', to: 'orders#mail'

  get '/unsubscribe/:signature', to: 'proxy_users#unsubscribe', as: 'unsubscribe'
  patch '/unsubscribe/:signature', to: 'proxy_users#confirm_unsubscribe', as: 'confirm_unsubscribe'

  # Must be the last route!
  match '*path', to: redirect { |_, request| "https://www.shopbeam.com#{request.fullpath}" }, via: :all
end
