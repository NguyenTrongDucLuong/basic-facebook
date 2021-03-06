Rails.application.routes.draw do

  root   'static_pages#home'
  get     '/about',     to: 'static_pages#about'
  get     '/signup',    to: 'users#new'
  get     '/login',     to: 'sessions#new'
  post    '/login',     to: 'sessions#create'
  delete  '/logout',    to: 'sessions#destroy'
  get     '/sociallogin', to: redirect('/auth/google_oauth2')
  get     'auth/:provider/callback', to: 'social_authentication#create'
  get     'auth/failure',   to: redirect('/')
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
