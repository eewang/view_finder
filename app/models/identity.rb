class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :token, :login_name, :avatar
  belongs_to :user
  validates_presence_of :uid, :provider, :token
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_from_hash(hash)
    find_by_provider_and_uid(hash["provider"], hash["uid"])
  end

  def self.update_from_hash(hash)
    auth = self.find_from_hash(hash)
    auth.update_attributes({
      :token =>      hash['credentials']['token'],
      :login_name => hash['info']['nickname'],
      :avatar =>     hash['info']['image']  
    })
    return auth
  end

  def self.create_from_hash(hash, user = nil)
    if user
      identity = Identity.create(
        :user_id => user.id, 
        :uid => hash["uid"], 
        :provider => hash["provider"], 
        :token => hash["credentials"]["token"], 
        :login_name => hash["info"]["nickname"], 
        :avatar => hash["info"]["image"]
        )
    else
      identity = Identity.new(
        :uid => hash["uid"], 
        :provider => hash["provider"], 
        :token => hash["credentials"]["token"], 
        :login_name => hash["info"]["nickname"], 
        :avatar => hash["info"]["image"]
        )
      identity.save
    end
    identity
  end

  def self.includes_instagram_user?(instagram_uid)
    self.find_by_uid(instagram_uid) ? true : false
  end

  def friends_list
    InstagramWrapper.new.user_follows(:user => self.uid)
  end

  def friends_media(friends_list)
    f_photos = {}
    friends_list.each do |f|
      if Identity.includes_instagram_user?(f.id)
        i = InstagramWrapper.new
        f_photos[f.id] ||= []
        f_photos[f.id] = (Photo.instagram_user_recent_media(:user => f.id).collect { |photo| photo }) # if Photo::TAGS.any? { |tag| photo.caption ? photo.caption.text.include?(tag) : false }
        f_photos[f.id].delete_if { |photo| photo.nil? }
      end
    end
    f_photos
  end

  def viewfinder_sorted_friends_list(friends_media)
    if friends_media
      friends_media.sort_by { |uid, photos| photos.size }.reverse
    end
  end


end
