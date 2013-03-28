class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id

  include Locatable

  acts_as_gmappable :process_geocoding => false

  def self.instagram_location_search(options)
    i = InstagramWrapper.new 
    i.filter_media_search(options).collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

  def self.instagram_tag_recent_media(options)
    i = InstagramWrapper.new 
    i.filter_tag_recent_media(options).collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

  def self.instagram_media_popular(options)
    i = InstagramWrapper.new 
    filtered_images = i.filter_media_popular(options)
    filtered_images.each do |pic|
      binding.pry
      Photo.save_instagram_photos(pic)
    end
  end

# '40.734771', '-73.990722
# :lat => '40.734771', :lon => '-73.990722'

  def self.save_instagram_photos(instagram_pic)
    @photo = Photo.where(:instagram_id => instagram_pic.id).first_or_create
    @photo.set_attributes(instagram_pic)
    @photo
  end

  def set_attributes(pic)
    self.image = pic.images.standard_resolution.url
    self.latitude = pic.location.latitude unless pic.location.nil?
    self.longitude = pic.location.longitude unless pic.location.nil?
    self.user_name = pic.user.full_name        
    self.location = pic.location.name unless pic.location.nil?
    self.link = pic.link
    self.instagram_id = pic.id
    self.caption = pic.caption.text unless pic.caption.nil?
    self.save
  end

  # def gmaps4rails_address
  #   self.street_address.collect do |address|
  #     unless address
  #       address = "188 Suffolk Street, New York, USA"
  #     end
  #   end
  # end

end
