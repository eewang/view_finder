class InstagramWrapper

  def self.acts_as_locatable(*queries)
    queries.each do |query|
      define_method "filter_#{query}" do |options|
        location_images = self.send(query, options).delete_if { |i| i.location.nil?}
        # @instagram_wrapper.media_search
        location_images
      end
    end
  end

  acts_as_locatable :tag_recent_media, :media_search, :user_recent_media, :media_popular, :user_media_feed

  def tag_recent_media(options)
    tag = options[:tag] ? options[:tag] : nil
    Instagram.tag_recent_media(tag)
  end

  def media_search(options)
    lat = options[:lat] ? options[:lat] : nil
    lon = options[:lon] ? options[:lon] : nil
    dis = options[:distance] ? options[:distance] : 1609.34
    Instagram.media_search(lat, lon, :distance => dis)
  end

  def media_popular(options)
    Instagram.media_popular(options)
  end

  def user_recent_media(options)
    instagram_user = options[:user] ? options[:user] : nil
    Instagram.user_recent_media(instagram_user)
  end

  def user_media_feed(options)
    
    Instagram.user_media_feed(options)
  end

end
