Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'user/registrations'
  }
  resources :drives
  resources :standby_dates, only: [:create, :destroy, :index]
  resources :standby_date_ranges, only: :create
  resources :companies

  root to: 'dashboard#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
