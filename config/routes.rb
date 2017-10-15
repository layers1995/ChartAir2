Rails.application.routes.draw do

#routes for reports on trips/fbos
  get '/feedback', to: "report#index"
  post '/feedback', to: "report#create"

#admin pages
  get '/admin_login', to: "admin#admin_login"
  post '/admin_create', to: "admin#admin_create"
  get '/admin_main', to: "admin#admin_main"
  post '/confirm_trip', to: 'admin#confirm_trip'
  get '/problem_trip', to: "admin#problem_trip"
  post '/post_problem', to: "admin#post_problem"
  post '/seen_report', to: "admin#seen_report"
  post '/emailed_request', to: "admin#emailed_request"
  
#fbo pages
  #get '/fbo_profile', to: "fbo_pages#fbo_profile"
  #get '/fbo_form', to: "fbo_pages#fbo_form"
  #get '/search', to: "fbo_pages#fbo_search"
  #get '/fbo_confirm', to: "fbo_pages#fbo_confirm_prices"
  #post '/search', to: "fbo_pages#fbo_search_results"
  #get '/fee_update_options', to: "fbo_pages#fbo_update_options"
  #get '/update_with_template', to: "fbo_pages#fbo_update_form"
  #get '/update_with_photo', to: "fbo_pages#fbo_update_photo"
  #get '/update_with_email', to: "fbo_pages#fbo_update_email"
  #post '/fbo_send_email', to: "fbo_pages#fbo_send_email"
  #get '/update_with_fax', to: "fbo_pages#fbo_update_fax"
  #get '/congrats', to: "fbo_page#congrats"
  #post '/confirm_fees', to: "fbo_pages#confirm_fees"

#pages for the user to view all of their previous trips
  get '/trips', to: 'trips#index'
  get '/report_trip', to: 'trips#report_trip'
  get '/book_trip', to: 'trips#book_trip'
  post '/book_trip', to: 'trips#new_trip'
  get '/trip_resolution', to: "trips#resolution"
  post '/resolve_trip', to: "trips#resolve_trip"

#pages used for the plan trip      
  get '/plantrip', to: 'plan_trip#trip_details'
  post '/plantrip', to: 'plan_trip#results'
  
#static pages
  get '/home',  to: 'static_pages#home'
  get '/help',  to:'static_pages#help'
  get '/about_us',    to: 'static_pages#about_us'
  get '/landing', to: 'static_pages#landing'

#user pages
  get '/new_user', to: 'users#new'
  get '/terms', to: 'users#terms'
  get '/request', to: 'users#request_account'
  post '/request', to: 'users#create_request'
  post '/create',  to: 'users#create'

#profile pages
  get '/profile', to: 'airplane_users#profile'
  post '/profileremove', to: 'airplane_users#remove_plane'
  get '/add_plane', to: 'airplane_users#new'
  post '/add_plane', to: 'airplane_users#create'

#login pages
  get '/login', to: "sessions#new"
  post '/login', to: "sessions#create"
  delete '/logout',  to: "sessions#destroy"

#root page
  root 'static_pages#landing'
  
#resources
  resources :users
  resources :airplanes
  resources :airplane_users
  resources :trips
  
end
