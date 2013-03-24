class Guess < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :state, :street_address

  belongs_to :user
  belongs_to :photo

  geocoded_by :street_address
  after_validation :geocode

end
