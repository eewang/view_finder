class AuthenticationsController < ApplicationController
  skip_before_filter :login_required

  def instagram_disable
    redirect_to root_path, :alert => "Please note that Instagram authentication has been disabled."
  end

  def index
    @authentications = Authentication.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authentications }
    end
  end

  def show
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authentication }
    end
  end

  def new
    @authentication = Authentication.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authentication }
    end
  end

  def edit
    @authentication = Authentication.find(params[:id])
  end

  def create
    session[:instagram] = nil
    auth = request.env["omniauth.auth"]
    unless @auth = Identity.find_from_hash(auth)
      @auth = Identity.create_from_hash(auth, current_user)
    end
    session[:instagram] ||= {}
    session[:instagram][:uid] = @auth.uid
    session[:instagram][:token] = @auth.token

    if @auth.user_id
      session[:user_id] = @auth.user_id
      redirect_to root_path, :notice => "Instagram authentication successful. You are now logged in."
    else
      redirect_to root_path, :notice => "Instagram authentication successful. Please signup for ViewFinder."
    end
  end

  def update
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      if @authentication.update_attributes(params[:authentication])
        format.html { redirect_to @authentication, notice: 'Authentication was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy

    respond_to do |format|
      format.html { redirect_to authentications_url }
      format.json { head :no_content }
    end
  end
end
