class PhotosController < ApplicationController
  skip_before_filter :login_required, :only => ["index"]

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
        user = current_user
        # Load game photos
        @photos = Photo.game_photos_random(@coordinates, radius, user, size)
        # Determines game metadata
        @photos.each do |p|
          p.locale_lat = LOCATION_GAMES[game.to_sym][:coordinates][0]
          p.locale_lon = LOCATION_GAMES[game.to_sym][:coordinates][1]
          p.save
        end
        # Loads game photo ids into user session
        self.create_game({:game => @game, :coordinates => @coordinates, :photos => @photos})
        @start_photo = session[game][:photos].empty? ? 0 : Photo.first_unguessed_photo(session[game][:photos], current_user)
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        # Perform asynchronous Instagram API call
        InstagramWorker.perform_async(@coordinates)
        # Convert game photos to map markers
        # @json = @photos.to_gmaps4rails
        # Render view
        render "index"
      end

      define_method "saved_#{game}_game" do 
        user = current_user
        photo_ids = session[game][:photos]
        @coordinates = session[game][:coordinates]
        @game = session[game][:game]
        @photos = photo_ids.collect do |id|
          @photo = Photo.find(id)
        end
<<<<<<< HEAD
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        if @guessed_count == @photos.size
          @start_photo = @photos.size
        else
          @start_photo = session[game][:photos].empty? ? 0 : Photo.first_unguessed_photo(photo_ids, current_user)
        end
=======
        @start_photo = session[game][:photos].empty? ? 0 : Photo.first_unguessed_photo(photo_ids, current_user)
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        binding.pry
>>>>>>> master
        render "index"
      end
    end
  end

  def self.social_games(*social_games)
    social_games.each do |game|
      define_method "#{game}" do |options = {}|
        @game = game
        @photos = Photo.send("#{game}", options)[0..5]
        @start_photo = 0 # CHANGE START PHOTO TO FIRST UNGUESSED
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        render "index"
      end

      # Add ability to save user friends games

    end
  end

  location_games :downtown, :midtown, :downtown_brooklyn #, :world_trade, :dumbo

  social_games :user_media_feed #, :user_recent_media

  def friend_feed
    friend_photos = params[:friend_name]
    @photos = session[:social][friend_photos.to_sym].shuffle[0..5].collect do |pic_id|
      Photo.find(pic_id)
    end
    @start_photo = 0 # CHANGE START PHOTO TO FIRST UNGUESSED
    @game = "friend/#{friend_photos}"
    @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
    self.create_game({:game => friend_photos, :photos => @photos})
    render "index"
  end

  def saved_friend_feed
    friend = params["friend_name"]
    user = current_user
    photo_ids = session[friend][:photos]
    # @coordinates = session[game][:coordinates]
    @game = "friend/#{session[friend][:game]}"
    @photos = photo_ids.collect do |id|
      @photo = Photo.find(id)
    end
    @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
    if @guessed_count == @photos.size
      @start_photo = @photos.size
    else
      @start_photo = session[friend][:photos].empty? ? 0 : Photo.first_unguessed_photo(photo_ids, current_user)
    end
    render "index"
  end    

  def create_game(options)
    game = options[:game]
    session[game] = nil
    session[game] ||= {}
    session[game][:game] ||= game
    photos = options[:photos]
    session[game][:photos] ||= []
    if options[:coordinates]
      coordinates = options[:coordinates]
      session[game][:coordinates] ||= coordinates
    end
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

  def show
    @game = params[:game]
    @photo = Photo.find(params[:id])
    @photo.locale_lat
    if !@photo.guessed_by?(current_user)
      @guess = @photo.guesses.build
    end

    if @photo.tagged?
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @photo }
      end
    else
      redirect_to root_path, :notice => "Sorry, that photo has not been tagged with #viewfinder or #vfyw"
    end
  end

  def play
    if params[:coordinates].empty?
      @photo = Photo.find(params["photo_id"])
      coordinates = PhotosController::LOCATION_GAMES[@photo.game][:coordinates].join(", ")
      @photo.locale_lat = coordinates.split(",")[0].gsub("[", "").to_f
      @photo.locale_lon = coordinates.split(",")[1].gsub("[", "").to_f
      @photo.save
    else
      coordinates = params[:coordinates]
    end
    game = params["game"]
    lat = coordinates.split(",")[0].gsub("[", "").to_f
    lon = coordinates.split(",")[1].gsub("[", "").to_f

    redirect_to photo_path(
      :id => params[:photo_id], 
      :locale_lat => lat, 
      :locale_lon => lon,
      :game => game
      )
  end

end
