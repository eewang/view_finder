require 'net/http'

class UsersController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :oauth_failure, :index]
  # GET /users
  # GET /users.json
  
  def oauth_failure
    user_code = params[:code]
    uri = URI('https://api.instagram.com/oauth/access_token/')
    HTTParty.post(uri, 
      {'client_id' => ENV['INSTAGRAM_APP_ID'],
        'client_secret' => ENV['INSTAGRAM_SECRET'],
        'grant_type' => 'authorization_code',
        'redirect_uri' => ENV['INSTAGRAM_REDIRECT'],
        'code' => user_code
      })
  end

  def index

    Instagram.configure do |config|
      config.client_id = ENV['INSTAGRAM_APP_ID']
      config.access_token = ENV['INSTAGRAM_TOKEN']
    end

    user_id = 305166995

    @recent_media = Instagram.user_recent_media(user_id)
    @popular_media = Instagram.media_popular
    @popular_media_with_locations = @popular_media.collect { |item| item if !item.location.nil? }

    @location_media = Instagram.media_search('40.734771', '-73.990722')
    @location_media.each do |pic|
      @photo = Photo.new({
        :image => pic.images.standard_resolution.url,
        :latitude => pic.location.latitude,
        :longitude => pic.location.longitude,
        :user_name => pic.user.full_name,        
        :location => pic.location.name,
        :link => pic.link,
        :caption => pic.caption.text
        })
      @photo.save
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
