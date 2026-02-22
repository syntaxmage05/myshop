Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "homepage#index"

  resources :products, only: [ :index ]
  resources :categories, only: [ :show ]
end
