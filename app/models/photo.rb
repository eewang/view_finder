class Photo < ActiveRecord::Base
  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id

  acts_as_gmappable :process_geocoding => false

  # def self.acts_as_instagrammable(api_query, options = {})
  #   define_singleton_method api_query do |options|
  #     # distance_default = 1000
  #     # options = {:distance => distance_default}.merge(opts)
  #     default_options = {
  #       :distance => 1000
  #     }

  #     options = options.reverse_merge(default_options)
      
  #     Instagram.send(api_query, options[:lat], options[:lon], options[:distance])
  #     # puts "Hello"
  #   end

    # define_singleton_method "instagram_#{api_query}_and_save" do 
    #   Photo.send("instagram_#{api_query}", options).collect do |item|
    #     Photo.save_instagram_photos(pic)
    #   end
    # end

  # end

# '40.734771', '-73.990722
# :lat => '40.734771', :lon => '-73.990722'

  # acts_as_instagrammable :user_recent_media

  def self.instagram_user_recent_media(instagram_user)
    Instagram.user_recent_media(instagram_user)
  end

  # acts_as_instagrammable :media_search, :lat => '40.734771', :lon => '-73.990722'

  def self.instagram_location_search(lat, lon, options = {})
    # finds photos within 1000 meters radius of the lat/lon coordinates
    options = {:distance => 1000}.merge(options)
    Instagram.media_search(lat, lon, options) 
  end

  def self.instagram_location_search_and_save(lat, lon, options = {})
    Photo.instagram_location_search(lat, lon, options).collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

  # acts_as_instagrammable :media_popular

  def self.instagram_popular_media_and_save
    Photo.instagram_popular_media_with_location.collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

  def self.instagram_popular_media_with_location
    popular_media = Instagram.media_popular.collect do |item|
      if item.location.nil?
        next
      else
        item
      end
    end
    popular_media.delete_if { |i| i.nil? }
  end

  # acts_as_instagrammable :tag_recent_media

  def self.save_instagram_photos(instagram_pic)
    @photo = Photo.where(:instagram_id => instagram_pic.id).first_or_create
    @photo.set_attributes(instagram_pic)
    @photo
  end

  def self.instagram_tag_recent_media(tag)
    Instagram.tag_recent_media(tag)
  end

  def self.instagram_tag_recent_media_and_save(tag)
    Photo.instagram_tag_recent_media(tag).collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

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

  def coordinates
    [self.latitude, self.longitude]
  end

  # def gmaps4rails_address
  #   self.street_address.collect do |address|
  #     unless address
  #       address = "188 Suffolk Street, New York, USA"
  #     end
  #   end
  # end

  def street_address
    unless self.latitude.nil?
      Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
    end
  end

end
