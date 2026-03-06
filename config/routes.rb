# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
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
      get "mpesa_payment"
    end
  end

  post "mpesa/initiate/:order_id", to: "mpesa#initiate", as: :mpesa_initiate
  post "mpesa/callback", to: "mpesa#callback"
  get "mpesa/status/:id", to: "mpesa#status", as: :mpesa_status
end
