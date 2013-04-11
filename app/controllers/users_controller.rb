require 'net/http'

class UsersController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create, :oauth_failure, :index, :signup_modal]
  # GET /users
  # GET /users.json
  
  # def oauth_failure
  #   user_code = params[:code]
  #   uri = URI('https://api.instagram.com/oauth/access_token/')
  #   HTTParty.post(uri, 
  #     {'client_id' => ENV['INSTAGRAM_APP_ID'],
  #       'client_secret' => ENV['INSTAGRAM_SECRET'],
  #       'grant_type' => 'authorization_code',
  #       'redirect_uri' => ENV['INSTAGRAM_REDIRECT'],
  #       'code' => user_code
  #     })
  # end

  def index
    @users = User.all
  end


  # GET /users/1
  # GET /users/1.json
  def show
    if params[:id].to_i == current_user.id 
      @user = User.find(current_user.id)
      @guesses = @user
      render "show" 
    else
      render "error"
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    redirect_to root_path, :notice => "Please click 'Sign Up'"
  end

  def signup_modal
    render :partial => "new_user_modal"
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new
    @user.name = params["name"]
    @user.password = params["password"]
    @user.email = params["email"]
    if @user.save
      session[:user_id] = @user.id
      if session[:instagram]
        @identity = Identity.find_by_uid(session[:instagram][:uid])
        @identity.user_id = @user.id
        @identity.save
      end
      respond_to do |f|
        f.js {
          render 'user_create.js.erb', :notice => "User created successfully!"
        }
        f.html { redirect_to root_path, :notice => "User created successfully!" }
      end
    else
      respond_to do |f|
      f.js {
        render 'user_create.js.erb', :notice => "Sorry, something went wrong. Please try again."
      }
      f.html { 
        redirect_to new_user_path, :notice => "Sorry, something went wrong. Please try again."
      }
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
