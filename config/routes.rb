# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "homepage#index"

  resources :products
  resources :categories
  resources :line_items
  resources :carts, only: [:show, :destroy]

  resources :orders, only: [:new, :create] do
    member do
      get :thank_you
    end
  end
end
