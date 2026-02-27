# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "homepage#index"

  resources :products, only: [ :show ]
  resources :categories, only: [ :show ]
  resources :line_items
  resources :carts, only: [:show, :destroy]
end
