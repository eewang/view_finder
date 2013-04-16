class SiteController < ApplicationController

  skip_before_filter :login_required, :only => ["home", "about"]

  def home
    flash[:auth_notice] = "Please login before authenticating"
    flash.keep
    if current_user
      @identity_auth = Identity.find_by_user_id(current_user.id)
      # client = Instagram.client(:access_token => @identity_auth.token)
      if @identity_auth
        client = Instagram.client(:access_token => session["instagram"][:token])
        @user_feed = client.user_media_feed
        @user_friends = Photo.instagram_friend_feed(@identity_auth)
        if !@user_friends.nil?
          @user_friends_array = []
          friend_count = @user_friends.size < 3 ? @user_friends.size : 3
          (1..friend_count).each do |i|
            friend = @user_friends[i-1]
            friend_photo_ids = friend[1].collect { |photo|
              photo.id
            }.delete_if { |item| item.nil? }
            friend_identity = Identity.find_by_uid(friend[0])
            @user_friends_array[i-1] ||= []
            @user_friends_array[i-1] << friend[0]
            @user_friends_array[i-1] << friend_identity.login_name
            @user_friends_array[i-1] << friend_identity.avatar
            @user_friends_array[i-1] << friend[1]
            session[:social] ||= {}
            session[:social][friend_identity.login_name.to_sym] ||= friend_photo_ids
          end
        end
      end
      user = User.where(:id => current_user[:id]).first
    else
      user = 0
    end
    @games = [:midtown, :downtown, :downtown_brooklyn]
    @myfavorite = @games.collect do |game|
      game_attributes = self.game_info(game)
      Photo.game_photos_random(
        game_attributes[0], 
        game_attributes[1],
        user, 
        game_attributes[2]
      )
    end
  end

  # LOAD A GAME INTO APPLICATION

  def game_info(game)
    [self.game_coordinates(game), self.game_radius(game), self.game_size(game)]
  end

  def game_coordinates(game)
    PhotosController::LOCATION_GAMES[game][:coordinates]
  end

  def game_radius(game)
    PhotosController::LOCATION_GAMES[game][:radius]
  end

  def game_size(game)
    PhotosController::LOCATION_GAMES[game][:size]
  end

  def about
  end

end




