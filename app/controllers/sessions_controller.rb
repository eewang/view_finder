class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => "destroy"

  def index
  end

  def new
  end

  def login_modal
    render :partial => "login_modal"
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      @instagram_identity = Identity.find_by_user_id(@user.id)
      if @instagram_identity
        session[:instagram] ||= {}
        session[:instagram][:uid] = @instagram_identity.uid
        session[:instagram][:token] = @instagram_identity.token
        client = Instagram.client(:access_token => @instagram_identity.token)
        test = client.user(@instagram_identity.uid)
        @instagram_identity.avatar = test.profile_picture
        @instagram_identity.save
      end
      # redirect_to root_path, :notice => "Logged in!"
    else
      # redirect_to login_path, :notice => "Invalid email or password"
    end

    respond_to do |f|
      f.js {
        render 'session_create.js.erb', :notice => "Logged in!"
      }
      f.html {}
    end

  end

  def destroy
    session[:user_id] = nil
    session[:instagram] = nil
    session[:social] = nil
    session[:downtown] = nil
    session[:downtown_brooklyn] = nil
    session[:midtown] = nil
    current_user = nil

    respond_to do |f|
      f.js { }
      f.html {
        redirect_to root_path, :notice => "Logged out!"
      }
    end
  end

  def auth_instagram
    render :text => "Hello world"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
