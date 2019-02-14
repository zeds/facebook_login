Rails.application.routes.draw do

  get 'posts/index'
  get 'posts/show'
  get 'posts/create'
  get 'posts/:id', to:'posts#show'
  root 'homes#index'
  get '/homes', to: 'homes#index'

  get 'homes/index'
  get 'names/index'
  get 'names/create'
  get 'names/index'
  post 'names/create'

  get 'usernames/index'
  post 'usernames/create'
  get 'mypages/index'

  # devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_for :users, controllers: { sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks' }

  # 一部分だけ変えたい時、devise_scopeを使う


  # 2019-02-02 15:30 omniauthをdevise_forの中に入れたいが、わからん！

  # devise_for :users, skip: [:sessions, :registrations, :confirmations, :omniauth_callbacks]
  # as :user do
  #   get 'sign_in', to: 'users/sessions#new', as: :new_user_session
  #   post 'sign_in', to: 'users/sessions#create', as: :user_session
  #   delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  #   get 'sign_up', to: 'users/registrations#new', as: :new_user_registration
  #   post 'sign_up', to: 'users/registrations#create', as: :user_registration
  #   get 'users/confirmation/new', to: 'users/confirmations#new', as: :new_user_confirmation
  #   get 'users/confirmation', to: 'users/confirmations#show', as: :user_confirmation
  #   # get 'auth/facebook', to: 'users/omniauth_callbacks', as: :user_facebook_omniauth_callback
  # end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
