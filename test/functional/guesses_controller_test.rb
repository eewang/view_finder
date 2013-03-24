require 'test_helper'

class GuessesControllerTest < ActionController::TestCase
  setup do
    @guess = guesses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:guesses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create guess" do
    assert_difference('Guess.count') do
      post :create, guess: { city: @guess.city, country: @guess.country, latitude: @guess.latitude, longitude: @guess.longitude, state: @guess.state, street_address: @guess.street_address }
    end

    assert_redirected_to guess_path(assigns(:guess))
  end

  test "should show guess" do
    get :show, id: @guess
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @guess
    assert_response :success
  end

  test "should update guess" do
    put :update, id: @guess, guess: { city: @guess.city, country: @guess.country, latitude: @guess.latitude, longitude: @guess.longitude, state: @guess.state, street_address: @guess.street_address }
    assert_redirected_to guess_path(assigns(:guess))
  end

  test "should destroy guess" do
    assert_difference('Guess.count', -1) do
      delete :destroy, id: @guess
    end

    assert_redirected_to guesses_path
  end
end
