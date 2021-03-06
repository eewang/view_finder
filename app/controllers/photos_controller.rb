class PhotosController < ApplicationController
  skip_before_filter :login_required, :only => ["index"]

  def self.location_games(*games)
    games.each do |game|
      define_method "#{game}" do
        @game = game
        @coordinates = Photo.location_games[game.to_sym][:coordinates]
        radius = Photo.location_games[game.to_sym][:radius]
        size = Photo.location_games[game.to_sym][:size]
        user = current_user
        @photos = Photo.game_photos_random(@coordinates, radius, user, size)
        @photos.each do |p|
          p.locale_lat = Photo.location_games[game.to_sym][:coordinates][0]
          p.locale_lon = Photo.location_games[game.to_sym][:coordinates][1]
          p.save
        end
        self.create_game({:game => @game, :coordinates => @coordinates, :photos => @photos})
        @start_photo = session[game][:photos].empty? ? 0 : Photo.first_unguessed_photo(session[game][:photos], current_user)
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        # InstagramWorker.perform_async(@coordinates)
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
        @guessed_count = @photos.count { |p| p.guessed_by?(current_user) }
        if @guessed_count == @photos.size
          @start_photo = @photos.size
        else
          @start_photo = session[game][:photos].empty? ? 0 : Photo.first_unguessed_photo(photo_ids, current_user)
        end
        render "index"
      end
    end
  end

  def self.social_games(*social_games)
    social_games.each do |game|
      define_method "#{game}" do |options = {:user => session[:instagram][:uid]}|
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
      coordinates = Photo.location_games[@photo.game][:coordinates].join(", ")
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
