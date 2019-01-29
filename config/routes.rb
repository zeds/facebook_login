Rails.application.routes.draw do
  get 'names/index'
  get 'names/create'
  get 'names/index'
  post 'names/create'

  get 'usernames/index'
  post 'usernames/create'
  get 'mypages/index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'homes#index'
  get '/homes', to: 'homes#index'
  get 'hello/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
