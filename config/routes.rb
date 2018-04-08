Rails.application.routes.draw do
  get '/new', to: 'registrations#new'
  get '/success', to: 'registrations#success'
  root 'registrations#new'
  resources :registrations

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
