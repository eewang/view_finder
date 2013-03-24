class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption

end
