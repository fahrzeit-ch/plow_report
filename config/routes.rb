# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :company do
    get 'routes/index'
    get 'routes/edit'
    get 'routes/create'
    get 'routes/update'
    get 'routes/delete'
  end
  use_doorkeeper do
    controllers authorizations: "authorizations"
  end

  namespace :api do
    defaults format: :json do
      namespace :v1 do
        resources :driver_applications, only: [:index, :create]
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
          resources :vehicles, only: [:index]
        end
        resources :companies, only: [] do
          resources :activities, only: [:index]
          resources :drivers, only: [:index]
          resources :sites, only: [:index]
          resources :vehicles, only: [:index]
        end
      end
    end
  end

  scope path: "/users" do
    resource :term_acceptances, only: %i[edit update]
  end

  devise_for :users, controllers: {
      registrations: "user/registrations",
      invitations: "user/invitations"
  }

  resources :driver_applications, only: %i[create show] do
    member do
      patch :accept
      get :review
    end
  end

  resources :companies do
    scope module: "company" do
      get :dashboard, to: "dashboard#index", as: "dashboard"
      resources :activities
      resources :vehicle_reassignments, only: %i[create] do
        collection do
          get :prepare
        end
      end
      resources :tours_reports
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
      resources :company_members, only: %i[create index destroy update] do
        collection do
          post :invite
          post :resend_invitation
        end
      end
      resources :drivers, only: %i[index create destroy edit update]
      resources :drives, only: %i[index destroy edit update]
      resources :standby_dates, only: %i[index destroy create] do
        collection do
          get :weeks
        end
      end
      resources :tours, only: %i[index destroy edit update] do
        resources :drives
      end
      resources :vehicles
      resources :routes
    end
  end

  authenticated :user do
    root "companies#index", as: :authenticated_root
  end

  get "/setup", to: "static_pages#setup", as: :setup
  get "/demo_login", to: "static_pages#demo_login", as: :demo_login
  get "/account_error", to: "static_pages#account_error", as: :account_error

  devise_scope :user do
    get "/", to: "devise/sessions#new"
  end

  root to: "devise/sessions#new"
end
