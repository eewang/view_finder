class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id

  def self.instagram_location_search(lat, lon)
    # finds photos within 1000 meters radius of the lat/lon coordinates
    Instagram.media_search(lat, lon) 
  end

  def self.instagram_popular_media
    Instagram.media_popular
  end

  def self.instagram_user_recent_media(instagram_user)
    Instagram.user_recent_media(user_id)
  end

  def self.instagram_location_search_and_save(lat, lon)
    @photo_collection = Photo.instagram_location_search(lat, lon).collect do |pic|
      @photo = Photo.where(:instagram_id => pic.id).first_or_create
      @photo.set_attributes(pic)
      @photo
    end
    @photo_collection
  end

  def set_attributes(pic)
    self.image = pic.images.standard_resolution.url
    self.latitude = pic.location.latitude
    self.longitude = pic.location.longitude
    self.user_name = pic.user.full_name        
    self.location = pic.location.name
    self.link = pic.link
    self.instagram_id = pic.id
    self.caption = pic.caption.text unless pic.caption.nil?
    self.save
  end

  def coordinates
    [self.latitude, self.longitude]
  end

  def street_address
    Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
  end

end
