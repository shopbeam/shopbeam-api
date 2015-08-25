Rails.application.routes.draw do
  resources :orders, only: :none do
    post :fill, on: :member
  end
end
