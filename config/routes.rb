Hke::Engine.routes.draw do
  
  resources :addresses

  resources :selections
  #get 'hke/landing_pages/:id1/:token1', to: 'hke/landing_pages#show'  
  #get 'hke/landing_pages/:id1', to: "hke/landing_pages#show", as: "landing"
  resources :cemeteries
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


  
  root to: "contact_people#index"
  get 'contact_people/index'
  get 'contact_people/edit'
  get 'contact_people/show'
end
