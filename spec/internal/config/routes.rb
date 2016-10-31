Rails.application.routes.draw do
  root to: 'orders#new'

  resources :orders, only: [:new, :create] do
    member do
      post :return
      post :final
    end
  end
end
