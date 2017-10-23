Rails.application.routes.draw do
  root to: 'normal_orders#new'

  resources :normal_orders, only: [:new, :create] do
    member do
      post :return
      post :final
    end
  end

  resources :oneclick_inscriptions, only: [:new, :create] do
    collection do
      post :finish
    end
  end

  resources :oneclick_orders, only: [:new, :create]
end
