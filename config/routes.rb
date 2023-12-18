Hke::Engine.routes.draw do
  resources :contact_people
  resources :addresses
  root to: "contact_people#index"
  get 'contact_people/index'
  get 'contact_people/edit'
  get 'contact_people/show'
end
