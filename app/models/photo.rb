class Photo < ActiveRecord::Base

  TAGS = ["#vfyw", "#viewfinder"]

  belongs_to :user
  has_many :guesses
  has_many :users, :through => :guesses

  attr_accessible :image, :latitude, :longitude, :user_name, :location, :link, :caption, :instagram_id, :locale_lat, :locale_lon

  geocoded_by :latitude => :lat, :longitude => :lon

  include Locatable::InstanceMethods
  extend Locatable::ClassMethods

  include Gameable

  # Build photo instances from Instagram query that has been filtered to remove non-geotagged images

  def self.acts_as_instagrammable(*queries)
    queries.each do |query|
      define_singleton_method "instagram_#{query}" do |options|
        i = InstagramWrapper.new
        filtered_images = i.send("filter_#{query}", options)
        filtered_images.collect do |pic|
          Photo.save_instagram_photos(pic)
        end
      end
    end
  end

  acts_as_gmappable :process_geocoding => false

  acts_as_instagrammable :media_search, :tag_recent_media, :media_popular, :user_media_feed, :user_recent_media

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

  def self.user_media_feed(options = {})
    @photos_all = Photo.instagram_user_media_feed({}).shuffle
    # @photos_tagged = @photos_all.collect do |photo|
    #   photo #if TAGS.any? { |tag| photo.caption.include?(tag) }
    # end
    # @photos = @photos_tagged.delete_if { |photo| photo.nil? } #.shuffle[0..4]
  end

  def self.follow_feeds(instagram_uid, rank)
    follow_hash = {}
    # Get all people an authenticated user follows
    follows = InstagramWrapper.new.user_follows(:user => instagram_uid)
    # Go through each user and determine how much they have tagged #vfyw or #viewfinder recently
    f_photos = []
    follows.each do |f|
      if Identity.find_by_uid(f.id)
        f_photos = Instagram.user_recent_media(f.id).collect do |photo|
          photo # if TAGS.any? { |tag| photo.caption ? photo.caption.text.include?(tag) : false }
        end
      end
      f_photos.delete_if { |photo| photo.nil? }
      follow_hash[f.id] ||= f_photos.size
    end
    sorted_follow_hash = follow_hash.sort_by { |name, count| count }.reverse
    @just_photos = Identity.find_by_uid(sorted_follow_hash[rank - 1][0]) ? Instagram.user_recent_media(sorted_follow_hash[rank - 1][0]) : []
    @player_photos = [
      sorted_follow_hash[rank - 1][0], 
      @just_photos]
    # Return the top three users
  end


  # LOCATION GAMEPLAY LOGIC

  # Filter photos by tags

  def self.tag_filter
    where(["caption LIKE ? OR caption LIKE ? ", "%#{TAGS[0]}%", "%#{TAGS[1]}%"])
    # collect do |tag|
    #   where(["caption LIKE ? ", "%#{tag}"])
    # end
  end

  # Return all photos that have been guessed by the user and have been tagged. Delete 'tag_filter' to remove tag

  def self.tagged_photos_guessed_by(user)
    includes(:guesses).where("guesses.user_id = #{user.id}").tag_filter
  end

  # Return all saved photos that have not been guessed by the user and have been tagged. Delete 'tag_filter 'to remove tag

  def self.tagged_photos_not_guessed_by(user)
    Photo.tag_filter.where("id NOT NULL") - Photo.tagged_photos_guessed_by(user)
  end

  # Check if photo is located within [distance] miles of [coordinates]

  def near?(coordinates, distance)
    true if self.distance_from_target_in_miles(coordinates) < distance
  end

  # Return a set of photos from the database within [distance] miles from [coordinates] that have not been guessed by [user]

  def self.game_photos_set(coordinates, distance, user)
    game_photos = Photo.tagged_photos_not_guessed_by(user).collect do |photo|
      photo unless photo.near?(coordinates, distance).nil?
    end
    game_photos.delete_if { |photo| photo.nil? }
  end

  # Return a randomized set of [size] photos (e.g., 10 photos) for game play

  def self.game_photos_random(coordinates, distance, user, size)
    Photo.game_photos_set(coordinates, distance, user).shuffle[0..size-1]
  end

  def game
    game_coords = {}
    distances = {}
    PhotosController::LOCATION_GAMES.each do |key, value|
      game_coords[key] ||= []
      game_coords[key] = value[:coordinates]
    end
    distances = game_coords.collect do |game, coords|
      dist = self.distance_from_target_in_miles(coords)
      distances[game] ||= dist      
    end
    @game = game_coords.keys[distances.index(distances.min)]
  end

end
