Rails.application.routes.draw do
  root 'registrations#new'
  post 'registrations', to: 'registrations#create'
  get 'registrations/:hashed_email', to: 'registrations#edit' 
  put 'registrations/:hashed_email', to: 'registrations#update'
  get 'registrations/:hashed_email/confirm', to: 'registrations#confirm'
  get 'registrations', to: 'registrations#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
