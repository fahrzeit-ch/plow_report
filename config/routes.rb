Rails.application.routes.draw do
  get 'static_pages/home'

  devise_for :users, controllers: {
      registrations: 'user/registrations'
  }
  resources :drives do
    collection do
      get :suggested_values
    end
  end
  resources :standby_dates, only: [:create, :destroy, :index]
  resources :standby_date_ranges, only: :create
  resource :driver, only: :create
  resource :recordings, only: [:create, :destroy] do
    put :finish
  end

  resources :companies do
    scope module: 'company' do
      get :dashboard, to: 'dashboard#index', as: 'dashboard'
      resources :drives, only: [:index, :destroy, :edit, :update]
      resources :standby_dates, only: [:index, :destroy, :create] do
        collection do
          get :weeks
        end
      end
      resources :company_members, only: [:create, :index, :destroy, :update] do
        collection do
          post :invite
          post :resend_invitation
        end
      end
      resources :drivers, only: [:index, :create, :destroy]
    end
  end

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  get '/setup', to: 'static_pages#setup', as: :setup

  root 'static_pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
