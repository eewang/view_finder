class InstagramWorker

  include Sidekiq::Worker
  
  def perform(coordinates)
    hash = {:lat => coordinates[0], :lon => coordinates[1]}
    # Photo.instagram_media_search(hash)
    # Photo.instagram_tag_recent_media(:tag => "viewfinder")
    # Photo.instagram_tag_recent_media(:tag => "vfyw")
  end

end