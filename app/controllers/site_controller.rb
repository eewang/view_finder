class SiteController < ApplicationController

  skip_before_filter :login_required, :only => ["home"]

  def home
    flash[:auth_notice] = "Please login before authenticating"
    flash.keep
    if current_user
      @identity_auth = Identity.find_by_user_id(current_user.id)
      # client = Instagram.client(:access_token => @identity_auth.token)
      if @identity_auth
        client = Instagram.client(:access_token => session["instagram"][:token])
        @user_feed = client.user_media_feed
        @player_1 = Photo.follow_feeds(@identity_auth.uid, 1)
        @player_1_avatar = Instagram.user(@player_1[0]).profile_picture
        @player_1_photos = @player_1[1]
        @player_2 = Photo.follow_feeds(@identity_auth.uid, 2)
        @player_2_avatar = Identity.find_by_uid(@player_2[0]) ? Instagram.user(@player_2[0]).profile_picture : []
        @player_2_photos = Identity.find_by_uid(@player_2[0]) ? @player_2[1] : []
      end
      # @user_feed = @identity_auth ? Photo.instagram_user_recent_media(:user => @identity_auth.uid) : nil
      user = User.where(:id => current_user[:id]).first
    else
      user = User.find(1)
    end
    @games = [:downtown, :midtown, :downtown_brooklyn]
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

end

  # def home
  #   user = User.where(:id => current_user[:id]).first
  #   @myfavorite = []

  #   union_square_coordinates = PhotosController::LOCATION_GAMES[:union_square][:coordinates]
  #   union_square_radius = PhotosController::LOCATION_GAMES[:union_square][:radius]
  #   union_square_size = 10

  #   thirty_rock_coordinates = PhotosController::LOCATION_GAMES[:thirty_rock][:coordinates]
  #   thirty_rock_radius = PhotosController::LOCATION_GAMES[:thirty_rock][:radius]
  #   thirty_rock_size = 10

  #   central_park_coordinates = PhotosController::LOCATION_GAMES[:central_park][:coordinates]
  #   central_park_radius = PhotosController::LOCATION_GAMES[:central_park][:radius]
  #   central_park_size = 10

  #   @union_square = Photo.game_photos_random(union_square_coordinates, union_square_radius, user, union_square_size)
  #   @central_park = Photo.game_photos_random(central_park_coordinates, central_park_radius, user, central_park_size)
  #   @thirty_rock = Photo.game_photos_random(thirty_rock_coordinates, thirty_rock_radius, user, thirty_rock_size)

  #   @myfavorite = [@union_square, @central_park, @thirty_rock]

  # end




