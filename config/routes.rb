Rails.application.routes.draw do
  devise_for :users
  resources :drives
  resources :standby_dates
  resources :standby_date_ranges, only: :create

  root to: 'dashboard#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
