class GuessesController < ApplicationController

  # GET /guesses
  # GET /guesses.json
  def index
    @guesses = Guess.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guesses }
    end
  end

  # GET /guesses/1
  # GET /guesses/1.json
  def show
    # if @photo.guessed_by?(current_user)
      current_guess = Guess.find(params[:id])
      @all_guesses = Guess.photo_guesses_sorted(current_guess.photo)

      if @all_guesses.size > 5
        @all_guesses = all_guesses.delete_if { |g| g.user.id == current_guess.user.id }
        @current_guess = current_guess
      end

      @user_in_top_5 = false
      @user_in_top_5 = true if @current_guess

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @guess }
      end
    # else
      # redirect_to photo_show(@photo)
    # end
  end

  # GET /guesses/new
  # GET /guesses/new.json
  def new
    @guess = Guess.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guess }
    end
  end

  # GET /guesses/1/edit
  def edit
    @guess = Guess.find(params[:id])
  end

  # POST /guesses
  # POST /guesses.json
  def create
    params.delete :controller
    params.delete :action
    
    guess = current_user.guesses.where(:photo_id => params[:photo_id]).first

    if guess.nil?
      target = Photo.where(:id => params[:photo_id]).first
      guess = current_user.guesses.create(params)
      guess.street_address = guess.coordinates_to_address
      guess.proximity_to_answer_in_feet = guess.distance_from_target_in_feet(target).round

      guess.save
    end
    
    url = "http://wheresthatgram.com/guesses/#{guess.id}"
    
    render :json => {:redirect_url => url }


    
    # if @guess.try(:has_valid_location?)
    #   @guess.save
    #   @guess.address_to_coordinates
    #   redirect_to guess_path(@guess)
    # else
    #   render "error"
    # end
  end

  # PUT /guesses/1
  # PUT /guesses/1.json
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

  # DELETE /guesses/1
  # DELETE /guesses/1.json
  def destroy
    @guess = Guess.find(params[:id])
    @guess.destroy

    respond_to do |format|
      format.html { redirect_to guesses_url }
      format.json { head :no_content }
    end
  end
end
