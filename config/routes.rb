Rails.application.routes.draw do
  # Health
  get "/up", to: proc { [200, {}, ["OK"]] }

  # Auth
  post "/login", to: "sessions#create"

  # Public
  resources :properties, only: [:index, :show]
  resources :bookings, only: [:index, :create, :show, :destroy]

  # Payments webhooks
  post "/payments/mpesa/stk_push", to: "payments#mpesa_stk_push"
  post "/payments/webhook/:provider", to: "payments#webhook"

  # Admin
  namespace :admin do
    resources :bookings, only: [:index, :show, :create, :update, :destroy]
    resources :prices, only: [:index, :create]
  end
end
