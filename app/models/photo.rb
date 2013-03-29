class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id

  include Locatable

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

  def self.save_instagram_photos(instagram_pic)
    @photo = Photo.where(:instagram_id => instagram_pic.id).first_or_create
    @photo.set_attributes(instagram_pic)
    @photo
  end

  def set_attributes(pic)
    begin
      self.image = pic.images.standard_resolution unless pic.images.nil
      self.latitude = pic.location.latitude unless pic.location.nil?
      self.longitude = pic.location.longitude unless pic.location.nil?
      self.user_name = pic.user.full_name        
      self.location = pic.location.name unless pic.location.nil?
      self.link = pic.link
      self.instagram_id = pic.id
      self.caption = pic.caption.text unless pic.caption.nil?
      self.save
    rescue => ex
      puts ex
    end
  end

end
