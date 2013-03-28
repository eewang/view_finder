class InstagramWrapper

# Instagram.tag_recent_media(id, *args)
# => Returns recent media (images) tagged with the id.

# Instagram.location_recent_media(id, *args)
# => Returns recent media nearby a given location id

# Instagram.media_search(lat, lng, options={})
# => Return recent media within a given distance (default 1000 m) of the lat/lng

# Instagram.media_popular(*args)
# => Return all popular media as defined by Instagram

# Instagram.user_liked_media(options={})
# => Returns media liked by an authenticated user

# Instagram.user_recent_media(*args)
# => Returns recent media for an authenticated user

  def self.acts_as_instagrammable(api_query, options = {})
    define_singleton_method("instagram_#{api_query}") do |options|      
      Instagram.send(api_query, options = {})
    end

    define_singleton_method "instagram_#{api_query}_and_save" do 
      Photo.send("instagram_#{api_query}", options).collect do |item|
        Photo.save_instagram_photos(pic)
      end
    end

  end

  # acts_as_instagrammable :media_search, :options => [:lat, :lon]

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

  # acts_as_instagrammable :user_recent_media

  def self.instagram_user_recent_media(instagram_user)
    Instagram.user_recent_media(instagram_user)
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

  def self.instagram_tag_recent_media(tag)
    Instagram.tag_recent_media(tag)
  end

  def self.instagram_tag_recent_media_and_save(tag)
    Photo.instagram_tag_recent_media(tag).collect do |pic|
      Photo.save_instagram_photos(pic)
    end
  end

end