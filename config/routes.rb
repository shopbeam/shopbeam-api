require 'sidekiq/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == Rails.application.secrets.admin_monitor_password
  end if Rails.env.production?

  mount Sidekiq::Web, at: '/admin/monitor'

  resources :orders, only: :none do
    post :fill, on: :member
  end
end
