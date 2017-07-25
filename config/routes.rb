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

#login pages

#root page
  root 'static_pages#home'
  
end
