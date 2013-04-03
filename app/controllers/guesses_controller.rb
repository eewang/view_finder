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
    @photo_guesses = Guess.photo_guesses_sorted(@guess.photo)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guess }
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
