namespace :viewfinder do

  desc "Get Instagram data"
  task :instagram => :environment do
    puts "testing instagram whenever task at #{Time.now}"
  end
  
end