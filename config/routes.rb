Rails.application.routes.draw do
  use_doorkeeper
  get 'static_pages/home'

  scope path: '/users' do
    resource :term_acceptances, only: [:edit, :update]
  end

  devise_for :users, controllers: {
      registrations: 'user/registrations',
      invitations: 'user/invitations'
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
      resources :hourly_rates
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
      resources :drivers, only: [:index, :create, :destroy, :edit, :update]
      resources :customer_to_site_transitions, only: [:new, :create]
      resources :customers do
        resources :sites do
          member do
            post :deactivate
            post :activate
          end
        end
      end
      resources :activities
    end
  end

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  get '/setup', to: 'static_pages#setup', as: :setup
  get '/welcome', to: 'static_pages#welcome', as: :welcome

  devise_scope :user do
    get "/", :to => "devise/sessions#new"
  end

  root :to => "devise/sessions#new"
end
