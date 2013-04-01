class SiteController < ApplicationController

  def home
    # @games = [:union_square, :central_park, :thirty_rock]
  	user = User.where(:id => current_user[:id]).first
    @myfavorite = []

		union_square_coordinates = PhotosController::LOCATION_GAMES[:union_square][:coordinates]
		union_square_radius = PhotosController::LOCATION_GAMES[:union_square][:radius]
		union_square_size = 10

		thirty_rock_coordinates = PhotosController::LOCATION_GAMES[:thirty_rock][:coordinates]
		thirty_rock_radius = PhotosController::LOCATION_GAMES[:thirty_rock][:radius]
		thirty_rock_size = 10

		central_park_coordinates = PhotosController::LOCATION_GAMES[:central_park][:coordinates]
		central_park_radius = PhotosController::LOCATION_GAMES[:central_park][:radius]
		central_park_size = 10

		@union_square = Photo.game_photos_random(union_square_coordinates, union_square_radius, user, union_square_size)
    @central_park = Photo.game_photos_random(central_park_coordinates, central_park_radius, user, central_park_size)
		@thirty_rock = Photo.game_photos_random(thirty_rock_coordinates, thirty_rock_radius, user, thirty_rock_size)

		@myfavorite = [@union_square, @central_park, @thirty_rock]

  end

end




