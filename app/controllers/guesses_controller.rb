class GuessesController < ApplicationController

  def index
    @guesses = Guess.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guesses }
    end
  end

  def show
    @guesses_count = 0
    # if @photo.guessed_by?(current_user)
      current_guess = Guess.find(params[:id])
      @all_guesses = Guess.photo_guesses_sorted(current_guess.photo)

      if @all_guesses.size > 5
        @all_guesses = all_guesses.delete_if { |g| g.user.id == current_guess.user.id }
        @current_guess = current_guess
      end

      @user_in_top_5 = false
      @user_in_top_5 = true if @current_guess

      @guesses_count = @current_guess.photo.guesses.size if @current_guess

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @current_guess }
      end
    # else
      # redirect_to photo_show(@photo)
    # end
  end

  def new
    @guess = Guess.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guess }
    end
  end

  def edit
    @guess = Guess.find(params[:id])
  end

  def create
    params.delete :controller
    params.delete :action
    
    guess = current_user.guesses.where(:photo_id => params[:photo_id]).first

    if guess.nil?
      target = Photo.where(:id => params[:photo_id]).first
      guess = current_user.guesses.build(params)
      guess.street_address = guess.coordinates_to_address
      guess.proximity_to_answer_in_feet = guess.distance_from_target_in_feet(target).round

      guess.save
    end
    
    url = guess_path(guess)
    
    render :json => {:redirect_url => url }

  end

  def update
    @guess = Guess.find(params[:id])

    respond_to do |format|
      if @guess.update_attributes(params[:guess])
        format.html { redirect_to @guess, notice: 'Guess was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @guess.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @guess = Guess.find(params[:id])
    @guess.destroy

    respond_to do |format|
      format.html { redirect_to guesses_url }
      format.json { head :no_content }
    end
  end
end
