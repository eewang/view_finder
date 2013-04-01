class SessionsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create, :destroy]

  def index
  end

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to root_path, :notice => "Logged in!"
    else
      redirect_to login_path, :notice => "Invalid email or password"
    end
  end

  def destroy
    session[:user_id] = nil
    session[:union_square] = nil
    redirect_to login_path, :notice => "Logged out!"
  end

  def auth_instagram
    render :text => "Hello world"
  end

  protected

  def auth_hash
      request.env['omniauth.auth']
    end

end
