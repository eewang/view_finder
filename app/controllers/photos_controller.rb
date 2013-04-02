class PhotosController < ApplicationController
  skip_before_filter :login_required, :only => ["index", "test"]

  LOCATION_GAMES = {
    :downtown => {
      :coordinates => [40.72410403, -74.003047943],
      :radius => 1.25,
      :size => 6
      },
    :midtown => {
      :coordinates => [40.754853,-73.984124],
      :radius => 1,
      :size => 6
      },
    :downtown_brooklyn => {
      :coordinates => [40.6920706, -73.984535],
      :radius => 1,
      :size => 6
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
        self.create_game(@game, @coordinates, @photos)
        # Perform asynchronous Instagram API call
        InstagramWorker.perform_async(@coordinates)
        # Convert game photos to map markers
        @json = @photos.to_gmaps4rails
        # Render view
        render "index"
      end

      define_method "saved_#{game}_game" do 
        user = User.where(:id => current_user[:id]).first
        photo_ids = session[game][:photos]
        @coordinates = session[game][:coordinates]
        @game = session[game][:game]
        @photos = photo_ids.collect do |id|
          @photo = Photo.find(id)
        end
        render "index"
      end
    end
  end

  # def self.get_games
  #   games = LOCATION_GAMES.collect do |key, value|
  #     key
  #   end
  # end

  location_games :downtown, :midtown, :downtown_brooklyn #, :world_trade, :dumbo

  def user_media_feed
    tags = Photo::TAGS
    @photos_all = Photo.instagram_user_media_feed({})
    @photos_tagged = @photos_all.collect do |photo|
      photo # if tags.any? { |tag| photo.caption.include?(tag) }
    end
    @photos = @photos_tagged.delete_if { |photo| photo.nil? } #.shuffle[0..4]
    binding.pry
    render "index"
  end

  def create_game(game, coordinates, photos)
    session[game] = nil
    session[game] ||= {}
    session[game][:photos] ||= []
    session[game][:coordinates] ||= coordinates
    session[game][:game] ||= game
    photos.each do |photo|
      session[game][:photos].push(photo.id)
    end
    session
  end

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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  def search
    render "search"
  end

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
