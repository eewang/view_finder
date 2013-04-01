class PhotosController < ApplicationController
  skip_before_filter :login_required, :only => ["index", "test"]

  LOCATION_GAMES = {
    :union_square => {
      :coordinates => [40.734771, -73.990722],
      :radius => 1,
      :size => 6
      },
    :thirty_rock => {
      :coordinates => [40.758956, -73.979464],
      :radius => 1,
      :size => 10
      },
    :times_square => {
      :coordinates => [40.7566, -73.9863],
      :radius => 1,
      :size => 10
      },      
    :central_park => {
      :coordinates => [40.773615,-73.971106],
      :radius => 3,
      :size => 10
      }
    # :world_trade => {
    #   :coordinates => [40.7117, -74.0125],
    #   :radius => 1,
    #   :size => 10
    #   },
    # :williamsburg => {
    #   :coordinates => [40.706336, -73.953482],
    #   :radius => 1,
    #   :size => 10
    #   }
  }

  def self.location_games(*games)
    games.each do |game|
      define_method "#{game}" do
        # Set game parameters
        @game = game
        @coordinates = LOCATION_GAMES[game.to_sym][:coordinates]
        radius = LOCATION_GAMES[game.to_sym][:radius]
        size = LOCATION_GAMES[game.to_sym][:size]
        user = User.where(:id => current_user[:id]).first
        # Load game photos
        @photos = Photo.game_photos_random(@coordinates, radius, user, size)
        @photos.each do |p|
          p.locale_lat = LOCATION_GAMES[game.to_sym][:coordinates][0]
          p.locale_lon = LOCATION_GAMES[game.to_sym][:coordinates][1]
          p.save
        end
        # Loads game photo ids into user session
        unless session[@game]
          session[@game] ||= []
          @photos.each do |photo|
            session[@game].push(photo.id)
          end
        end
        # Perform asynchronous Instagram API call
        InstagramWorker.perform_async(@coordinates)
        # Convert game photos to map markers
        @json = @photos.to_gmaps4rails
        # Render view
        render "index"
      end
    end
  end

  def saved_union_square_game
    photo_ids = session[:union_square]
    @photos = photo_ids.collect do |id|
      Photo.find(id)
    end
    render "index"
  end

  def saved_thirty_rock_game
    photo_ids = session[:thirty_rock]
    @photos = photo_ids.collect do |id|
      Photo.find(id)
    end
    render "index"
  end

  def saved_central_park_game
    photo_ids = session[:central_park]
    @photos = photo_ids.collect do |id|
      Photo.find(id)
    end
    render "index"
  end

  location_games :union_square, :thirty_rock, :central_park, :times_square #, :world_trade, :dumbo

  def photo_tag
    @photos = Photo.instagram_tag_recent_media({:tag => "vfyw"})
    @json = @photos.to_gmaps4rails
    render "index"
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @game = params[:game]
    @photo = Photo.find(params[:id])
    @photo.locale_lat
    if !@photo.guessed_by?(current_user)
      @guess = @photo.guesses.build
    end

    # @photo_json = JSON.parse(@photo.to_json)
    # @photo_json["locale_lat"] = params[:locale_lat]
    # @photo_json["locale_lon"] = params[:locale_lon]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  def search
    render "search"
  end

  # def index
  #   @search_query = params[:search_text]
  #   @search_distance = params[:distance]
  #   search = Geocoder.search(@search_query)
  #   unless search.empty?
  #     search_lat = search[0].latitude
  #     search_lon = search[0].longitude
  #     @photos = Photo.instagram_location_search_and_save(
  #       search_lat, 
  #       search_lon,
  #       {:distance => @search_distance})
  #     render "index"
  #   else
  #     render "/guesses/error"
  #   end
  #   # @json = Photo.all.to_gmaps4rails
  # end

  def play
    coordinates = params[:coordinates]
    game = params[:game]
    lat = coordinates.split(",")[0].gsub("[", "").to_f
    lon = coordinates.split(",")[1].gsub("[", "").to_f
    redirect_to photo_path(params[:photo_id], :locale_lat => lat, :locale_lon => lon, :game => game)
  end

  def index_popular
    @photos = Photo.instagram_media_popular({})

    render "index"
  end

end
