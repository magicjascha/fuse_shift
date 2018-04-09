Rails.application.routes.draw do
  root 'registrations#new'
  post 'registrations/', to: 'registrations#create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
