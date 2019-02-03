Rails.application.routes.draw do

  get 'homes/index'
  get 'names/index'
  get 'names/create'
  get 'names/index'
  post 'names/create'

  get 'usernames/index'
  post 'usernames/create'
  get 'mypages/index'

  # devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # 2019-02-02 15:30 omniauthをdevise_forの中に入れたいが、わからん！

  devise_for :users, skip: [:sessions]
  as :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    post 'sign_in', to: 'users/sessions#create', as: :user_session
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  root 'homes#index'
  get '/homes', to: 'homes#index'
  get 'hello/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
