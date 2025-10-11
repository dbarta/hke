Hke::Engine.routes.draw do

  # System Admin Routes
  namespace :admin do
    resources :communities do
      resources :users, controller: 'community_users'
    end

    resource :system_preferences, only: [:show, :edit, :update]
    post :switch_to_community, to: "dashboard#switch_to_community"
    root to: 'dashboard#show'
  end

  # Community Admin Routes (existing + enhanced)
  resources :logs, only: [:index]
  resources :cemeteries
  resources :communities, only: [:show, :edit, :update]  # Limited for community admins
  resources :future_messages do
    member do
      post :blast
      post :toggle_approval
    end
    collection do
      get :approve
      post :bulk_approve
      post :approve_all
      post :disapprove_all
    end
  end

  resources :csv_imports, only: [:new, :create, :show, :index]
  resources :message_management, only: [:index, :show]
  resources :landing_pages
  resources :contact_people do
    collection do
      post :index
      post :import_csv
    end
  end
  resources :deceased_people do
    collection do
      post :index
      post :import_csv
    end
  end
  resources :community_preferences

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      post 'twilio/sms/status', to: 'twilio_callback#sms_status'
      resource :system, only: [:show, :edit, :update, :create]
      resources :cemeteries
      resources :communities
      resources :future_messages do
        member do
          post :blast
        end
      end
      resources :deceased_people
      resources :contact_people
      resources :relations
    end
  end


  # Role-based dashboard routing
  root to: "dashboard#show"
  get "contact_people/index"
  get "contact_people/edit"
  get "contact_people/show"
end
