require 'geocoder'

class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id

  geocoded_by :latitude => :lat, :longitude => :lon

  include Locatable::InstanceMethods
  extend Locatable::ClassMethods

  include Gameable

  # Build photo instances from Instagram query that has been filtered to remove non-geotagged images

  def self.acts_as_instagrammable(query)
    define_singleton_method "instagram_#{query}" do |options|
      i = InstagramWrapper.new
      filtered_images = i.send("filter_#{query}", options)
      filtered_images.collect do |pic|
        Photo.save_instagram_photos(pic)
      end
    end
  end

  acts_as_gmappable :process_geocoding => false

  acts_as_instagrammable :media_search
  acts_as_instagrammable :tag_recent_media
  acts_as_instagrammable :media_popular

  # Find/create photo in database related to Instagram pic

  def self.save_instagram_photos(instagram_pic)
    @photo = Photo.where(:instagram_id => instagram_pic.id).first_or_create
    @photo.set_attributes(instagram_pic)
    @photo
  end

  # Create/update attributes of a photo based on Instagram image attributes

  def set_attributes(pic)
    self.image = pic.images.standard_resolution.url unless pic.images.nil
    self.latitude = pic.location.latitude
    self.longitude = pic.location.longitude
    self.user_name = pic.user.full_name        
    self.location = pic.location.name unless pic.location.nil?
    self.link = pic.link
    self.instagram_id = pic.id
    self.caption = pic.caption.text unless pic.caption.nil?
    self.save
  end

  # Check if the photo has been guessed on by the user

  def guessed_by?(user)
    self.guesses.all.collect { |guess| guess.user.id }.include?(user.id)
  end

  # Return a set of photos from the database within [distance] miles from [coordinates] that have not been guessed by [user]

  def self.game_photos_set(coordinates, distance, user)
    game_photos = Photo.photos_not_guessed_by(user).collect do |photo|
      photo unless photo.near?(coordinates, distance).nil?
    end
    game_photos.delete_if { |photo| photo.nil? }
  end

  # Return a randomized set of [size] photos (e.g., 10 photos) for game play

  def self.game_photos_random(coordinates, distance, user, size)
    Photo.game_photos_set(coordinates, distance, user).shuffle[0..size-1]
  end

  # Return all photos that have been guessed by the user

  def self.photos_guessed_by(user)
    includes(:guesses).where("guesses.user_id = #{user.id}")
  end

  # Return all saved photos that have not been guessed by the user

  def self.photos_not_guessed_by(user)
    Photo.where("id NOT NULL") - Photo.photos_guessed_by(user)
  end

  # Check if photo is located within [distance] miles of [coordinates]

  def near?(coordinates, distance)
    true if self.distance_from_target_in_miles(coordinates) < distance
  end

end
