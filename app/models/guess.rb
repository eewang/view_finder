class Guess < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :state, :street_address, :photo_id

  belongs_to :user
  belongs_to :photo

  delegate :latitude, :longitude, :image, :user_name, :location, :guesses, :to => :photo, :prefix => true

  delegate :name, :email, :to => :user, :prefix => true

  include Locatable

  geocoded_by :street_address
  after_validation :geocode

  def distance_from_target_in_feet
    self.distance_from_target_in_miles * 5280
  end

  def distance_from_target_in_miles
    Geocoder::Calculations.distance_between(self.coordinates, self.photo.coordinates)
  end

  def photo_guesses_sorted
    self.photo_guesses.sort_by { |g| g.distance_from_target_in_feet }
  end

  def set_attributes(params, guesser)
    self.street_address = params[:guess][:street_address]
    self.photo = Photo.find_by_id(params[:guess][:photo_id])
    self.user = guesser
  end

end
