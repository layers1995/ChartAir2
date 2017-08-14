Rails.application.routes.draw do

#pages for the user to view all of their previous trips
  get '/trips', to: 'trips#index'
  get '/report_trip', to: 'trips#report_trip'

#pages used for the plan trip      
  get '/plantrip', to: 'plan_trip#trip_details'
  post '/plantrip', to: 'plan_trip#results'
  
#static pages
  get '/home',  to: 'static_pages#home'
  get '/help',  to:'static_pages#help'
  get '/feedback',  to: 'static_pages#feedback'
  get  '/about_us',    to: 'static_pages#about_us'

#user pages
  get '/new_user', to: 'users#new'
  post '/new_user',  to: 'users#create'
  
  get '/profile', to: 'users_airplanes#profile'
  get '/profileremove', to: 'users_airplanes#remove_plane'
  post '/profile', to: 'users_airplanes#add_plane'

#login pages
  get '/login', to: "sessions#new"
  post '/login', to: "sessions#create"
  delete '/logout',  to: 'sessions#destroy'

#root page
  root 'sessions#new'
  
#resources
  resources :users
  resources :airplanes
  resources :users_airplanes
  
end
