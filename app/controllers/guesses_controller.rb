class GuessesController < ApplicationController

  def index
    @guesses = Guess.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guesses }
    end
  end

  def show
    @guess = Guess.find(params[:id])
    if @guess.photo.guessed_by?(current_user)
      @photo_guesses = Guess.photo_guesses_sorted(@guess.photo)
      @photo_guesses = @photo_guesses.shift(8) if @photo_guesses.size > 8
      game = @guess.photo.game

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @guess }
      end
    else
      redirect_to photo_path(@guess.photo), :alert => "You have to guess first, cheater!"
    end
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

  # POST /guesses
  def create

    # sample params from ajax
      # {latitude: "40.754853", longitude: "-73.984124", photo_id: 142}

    # get params ready for mass assignment
    params.delete(:action)
    params.delete(:controller)

    # => Find out if the user already made a guess on that photo.
    guess = current_user.guesses.where(:photo_id => params[:photo_id]).first

    # => If there is no guess, create one.
    if guess.nil?
      target = Photo.where(:id => params[:photo_id]).first
      guess = current_user.guesses.build(params)
      guess.street_address = guess.coordinates_to_address
      guess.proximity_to_answer_in_feet = guess.distance_from_target_in_feet(target).round

      guess.save
    end

    # => Instead of rendering a view or redirecting, this action renders a redirect url in a json object
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
