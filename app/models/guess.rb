class Guess < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :state, :street_address, :photo_id

  belongs_to :user
  belongs_to :photo

  include Locatable

  geocoded_by :street_address
  after_validation :geocode

  def distance_from_target_in_feet
    self.distance_from_target_in_miles * 5280
  end

  def distance_from_target_in_miles
    Geocoder::Calculations.distance_between(self.coordinates, self.photo.coordinates)
  end

end
