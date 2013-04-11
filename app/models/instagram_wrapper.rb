class InstagramWrapper

  def self.acts_as_locatable(*queries)
    queries.each do |query|
      define_method "filter_#{query}" do |options|
        location_images = self.send(query, options).delete_if { |i| i.location.nil?}
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
    dis = options[:distance] ? options[:distance] : 2012
    Instagram.media_search(lat, lon, :distance => dis)
  end

  def media_popular(options)
    Instagram.media_popular(options)
  end

  def user_recent_media(options)
    instagram_user_id = options[:user] ? options[:user] : nil
    instagram_user = Identity.find_by_uid(instagram_user_id)
    Instagram.user_recent_media(:user => instagram_user_id, :access_token => instagram_user.token)
  end

  def user_media_feed(options)
    Instagram.user_media_feed(options)
  end

  def user_follows(options)
    instagram_user_id = options[:user] ? options[:user] : nil
    instagram_user = Identity.find_by_uid(instagram_user_id)
    Instagram.user_follows(:user => instagram_user_id, :access_token => instagram_user.token)
  end

end
