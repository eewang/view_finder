class InstagramWorker

  include Sidekiq::Worker
  
  def perform(coordinates)
    hash = {:lat => coordinates[0], :lon => coordinates[1]}
    Photo.instagram_media_search(hash)
  end

end