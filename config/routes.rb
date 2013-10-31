require 'sidekiq/web'

ViewFinder::Application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'

  get '/instagram' => 'authentications#instagram_disable', :as => :instagram_disable
  match '/auth/instagram/callback/' => 'authentications#create'
  match '/auth/failure', :to => 'authentications#failure'

  root :to => 'site#home'
  get 'login_modal' => 'sessions#login_modal'
  get 'signup_modal' => 'users#signup_modal'

  Photo.location_games.each do |key, value|
    get "photos/#{key.to_s}" => "photos##{key.to_s}"
    post "photos/#{key.to_s}" => 'photos#play'
    get "users/:id/games/#{key.to_s}" => "photos#saved_#{key.to_s}_game"
    post "users/:id/games/#{key.to_s}" => "photos#play"
  end

  get "photos/friend/:friend_name" => "photos#friend_feed", :as => :friend_feed
  post "photos/friend/:friend_name" => "photos#play"
  get "users/:id/:friend_name" => "photos#saved_friend_feed"
  post "users/:id/:friend_name" => "photos#play"

  get "photos/user_media_feed" => "photos#user_media_feed"

  post "photos/user_media_feed" => "photos#play"
  get 'photos/:id' => 'photos#show', :as => 'photo'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'

  get 'photos/search' => 'photos#search'
  get 'photos/index' => 'photos#index'

  get 'photos/popular' => 'photos#index_popular'
  get 'photos/vfyw' => 'photos#photo_tag'

  get 'users/:id/feed' => "photos#user_media_feed"

  get 'about' => 'site#about', :as => "about"

  resources :users, :sessions, :authentications, :guesses

end
