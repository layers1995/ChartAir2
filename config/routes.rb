Rails.application.routes.draw do

#pages used for the plan trip      
  get '/plantrip', to: 'plan_trip#trip_details'
  get '/results', to: 'plan_trip#results'
  
#static pages
  get '/home',  to: 'static_pages#home'
  get '/help',  to:'static_pages#help'
  get '/feedback',  to: 'static_pages#feedback'
  get  '/about_us',    to: 'static_pages#about_us'

#user pages
  get '/new_user', to: 'users#new'
  post '/new_user',  to: 'users#create'
  
  get '/profile', to: 'users#profile'

#login pages
  get '/login', to: "sessions#new"
  post '/login', to: "sessions#create"
  delete '/logout',  to: 'sessions#destroy'

#root page
  root 'sessions#new'
  
#resources
  resources :users
  
end
