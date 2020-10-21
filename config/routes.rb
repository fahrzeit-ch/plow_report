Rails.application.routes.draw do

  use_doorkeeper do
    controllers authorizations: 'authorizations'
  end
  get 'static_pages/home'

  namespace :api do
    defaults format: :json do
      namespace :v1 do
        resources :drivers, only: [:index] do
          resources :activities, only: [:index]
          resources :sites, only: [:index]
          resources :tours, only: %i[index create update destroy] do
            collection do
              get :history
            end
          end
          resources :drives, only: %i[index create update destroy] do
            collection do
              get :history
            end
          end
          resources :standby_dates, only: [:index]
        end
        resources :companies, only: [] do
          resources :activities, only: [:index]
          resources :drivers, only: [:index]
          resources :sites, only: [:index]
        end
      end
    end
  end

  scope path: '/users' do
    resource :term_acceptances, only: %i[edit update]
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
  resources :standby_dates, only: %i[create destroy index]
  resources :standby_date_ranges, only: :create
  resource :driver, only: :create
  resource :recordings, only: %i[create destroy] do
    put :finish
  end

  resources :driver_applications, only: %i[create show] do
    member do
      patch :accept
      get :review
    end
  end

  resources :companies do
    scope module: 'company' do
      resources :hourly_rates
      get :dashboard, to: 'dashboard#index', as: 'dashboard'
      resources :drives, only: %i[index destroy edit update]
      resources :tours, only: %i[index destroy edit update] do
        resources :drives
      end
      resources :standby_dates, only: %i[index destroy create] do
        collection do
          get :weeks
        end
      end
      resources :company_members, only: %i[create index destroy update] do
        collection do
          post :invite
          post :resend_invitation
        end
      end
      resources :drivers, only: %i[index create destroy edit update]
      resources :customer_to_site_transitions, only: %i[new create]
      resources :customers do
        resources :sites do
          member do
            get :area
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
  get '/demo_login', to: 'static_pages#demo_login', as: :demo_login

  devise_scope :user do
    get "/", :to => "devise/sessions#new"
  end

  root :to => "devise/sessions#new"
end
