Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',               to: 'static_pages#help'
  get    '/about',              to: 'static_pages#about'
  get    '/contact',            to: 'static_pages#contact'
  get    '/signup',             to: 'users#new'
  post   '/signup',             to: 'users#create'
  get    '/login',              to: 'sessions#new'
  post   '/login',              to: 'sessions#create'
  delete '/logout',             to: 'sessions#destroy'
  get    '/inventory',          to: 'inventory#new'
  post   '/inventory',          to: 'inventory#create'
  get    '/inventory/show',     to: 'inventory#show'
  post   '/inventory/show',     to: 'inventory#view'
  get    '/inventory/history',  to: 'inventory#history'
  get    '/admin',              to: 'admin#view'
  post   '/admin',              to: 'admin#retrieve'
  get    '/admin/download',     to: 'admin#download'
  get    '/admin/download_reset', to: 'admin#download_reset'
  get    '/orders/download_reset', to: 'orders#download_reset'
	get    '/orders/cancel',      to: 'orders#cancel'
	get    '/orders/purge',       to: 'orders#purge'
	get    '/users/purge',        to: 'users#purge'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :orders
  resources :cuisines,            only: [:new, :index, :create]
end
