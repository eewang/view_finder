require 'sidekiq/web'

ViewFinder::Application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'

  match 'auth/instagram/callback/' => 'authentications#create'

  root :to => 'site#home'
  
  PhotosController::LOCATION_GAMES.each do |key, value|
    get "photos/#{key.to_s}" => "photos##{key.to_s}"
    post "photos/#{key.to_s}" => 'photos#play'
    get "users/:id/#{key.to_s}" => "photos#saved_#{key.to_s}_game"
    post "users/:id/#{key.to_s}" => "photos#play"
  end

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'

  get 'photos/search' => 'photos#search'
  get 'photos/index' => 'photos#index'

  get 'photos/popular' => 'photos#index_popular'
  get 'photos/vfyw' => 'photos#photo_tag'
  resources :users, :sessions, :authentications, :guesses

  get 'photos/:id' => 'photos#show', :as => 'photo'

end
