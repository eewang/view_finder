namespace :app do

  desc "Get Instagram data with #viewfinder"
  task :viewfinder => :environment do
    puts "Saved #viewfinder photos at #{Time.now}"
    Photo.instagram_tag_recent_media(:tag => "viewfinder")
  end

  desc "Get Instagram data with #vfyw"
  task :vfyw => :environment do
    puts "Saved #vfyw photos at #{Time.now}"
    Photo.instagram_tag_recent_media(:tag => "vfyw")
  end

  desc "Whenever gem test"
  task :testcron => :environment do
    puts "Testing cron tab successful at #{Time.now}"
  end

  # desc "Get Instagram data for location games"
  # task :location => :environment do
  #   Photo.get_game_coordinates.each do |coordinates|
  #     hash = {:lat => coordinates[0], :lon => coordinates[1]}
  #     binding.pry
  #     # Photo.instagram_media_search(hash)
  #   end
  # end
  
end