Hke::Engine.routes.draw do

  resources :selections
  # get 'hke/landing_pages/:id1/:token1', to: 'hke/landing_pages#show'
  # get 'hke/landing_pages/:id1', to: "hke/landing_pages#show", as: "landing"
  resources :cemeteries
  resources :communities
  resources :future_messages
  resources :sms_messages
  resources :landing_pages
  resources :contact_people do
    collection do
      post :index
    end
  end
  resources :deceased_people do
    collection do
      post :index
    end
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :system, only: [:show, :edit, :update, :create]
      resources :cemeteries
      resources :communities
      resources :future_messages
        member do
          post :send
      end
      resources :deceased_people
      resources :contact_people
      resources :relations
    end
  end


  root to: "contact_people#index"
  get "contact_people/index"
  get "contact_people/edit"
  get "contact_people/show"
end
