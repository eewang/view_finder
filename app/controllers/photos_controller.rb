class PhotosController < ApplicationController
  skip_before_filter :login_required, :only => "index"

  # GET /photos
  # GET /photos.json
  def search
    render "search"
  end

  def index
    @search_query = params[:search_text]
    @search_distance = params[:distance]
    search = Geocoder.search(@search_query)
    unless search.empty?
      search_lat = search[0].latitude
      search_lon = search[0].longitude
      @photos = Photo.instagram_location_search_and_save(
        search_lat, 
        search_lon,
        {:distance => @search_distance})
      render "index"
    else
      render "/guesses/error"
    end
    # @json = Photo.all.to_gmaps4rails
  end

  def index_location_1
    @photos = Photo.instagram_location_search_and_save('40.734771', '-73.990722')
    @json = @photos.to_gmaps4rails
    render "index"
  end

 def index_location_2
    @photos = Photo.instagram_location_search_and_save('40.758956', '-73.979464')
    @json = @photos.to_gmaps4rails
    render "index"
  end

  def index_popular
    @photos = Photo.instagram_popular_media_and_save

    render "index"
  end

  def photo_tag
    @photos = Photo.instagram_tag_recent_media_and_save('vfyw')
    @json = @photos.to_gmaps4rails
    render "index"
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photo = Photo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(params[:photo])

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render json: @photo, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end
end
