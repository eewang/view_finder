class Guess < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :state, :street_address, :photo_id

  belongs_to :user
  belongs_to :photo

  geocoded_by :street_address
  after_validation :geocode

  def distance_from_target_in_miles
    Geocoder::Calculations.distance_between(self.coordinates, self.photo.coordinates)
  end

  def distance_from_target_in_feet
    self.distance_from_target_in_miles * 5280
  end

  def coordinates
    [self.latitude, self.longitude]
  end

  def convert_address_to_coordinates
    query = Geocoder.search(self.street_address)
    query_lat = query[0].latitude
    query_lon = query[0].longitude
    self.set_coordinates(query_lat, query_lon)
  end

  def is_valid?
    true unless Geocoder.search(self.street_address).empty?
  end

  def set_coordinates(lat, lon)
    self.latitude = lat
    self.longitude = lon
  end

end
