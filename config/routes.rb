Rails.application.routes.draw do
  get 'contact_persons/new'

  root 'registrations#new'
  post 'registrations', to: 'registrations#create'
  get 'registrations/:hashed_email', to: 'registrations#edit' 
  put 'registrations/:hashed_email', to: 'registrations#update'
  get 'registrations/:hashed_email/confirm', to: 'registrations#confirm'
  delete 'registrations/:hashed_email', to: 'registrations#delete'
  get 'registrations', to: 'registrations#index'

  get 'login', to: 'contact_persons#new'
  post 'login', to: 'contact_persons#create'
  get 'logout', to: 'contact_persons#delete'
  get 'contact_persons/:hashed_email', to: 'contact_persons#confirm', as: 'contact_person_confirm'
  get 'clean_session', to: 'contact_persons#clean_session'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
