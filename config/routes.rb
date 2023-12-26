Hke::Engine.routes.draw do
  resources :contact_people
  resources :addresses
  resources :landing_pages
  resources :deceased_people
  
  root to: "contact_people#index"
  get 'contact_people/index'
  get 'contact_people/edit'
  get 'contact_people/show'
end
