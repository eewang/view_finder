require 'sidekiq/web'

ViewFinder::Application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'

  match 'auth/instagram/callback/' => 'authentications#create'

  root :to => 'site#home'
  
  post '/photos/union_square' => 'photos#play'
  post '/photos/times_square' => 'photos#play'
  post '/photos/thirty_rock' => 'photos#play'
  post '/photos/central_park' => 'photos#play'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'

  get 'photos/search' => 'photos#search'
  get 'photos/index' => 'photos#index'

  get 'photos/union_square' => 'photos#union_square'
  get 'users/:id/union_square' => 'photos#saved_union_square_game'
  post 'users/:id/union_square' => 'photos#play'

  get 'photos/thirty_rock' => 'photos#thirty_rock'
  get 'users/:id/thirty_rock' => 'photos#saved_thirty_rock_game'
  post 'users/:id/thirty_rock' => 'photos#play'

  get 'photos/times_square' => 'photos#times_square'
  get 'users/:id/times_square' => 'photos#saved_times_square_game'
  post 'users/:id/times_square' => 'photos#play'

  get 'photos/central_park' => 'photos#central_park'
  get 'users/:id/central_park' => 'photos#saved_central_park_game'
  post 'users/:id/central_park' => 'photos#play'


  get 'photos/popular' => 'photos#index_popular'
  get 'photos/vfyw' => 'photos#photo_tag'
  resources :users, :sessions, :authentications, :guesses

  get 'photos/:id' => 'photos#show', :as => 'photo'

end
