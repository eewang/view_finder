class SiteController < ApplicationController

  def home
    @union_square = Photo.instagram_media_search({:lat => '40.734771', :lon => '-73.990722'}).first
    @thirty_rock = Photo.instagram_media_search({:lat => '40.758956', :lon => '-73.979464'}).first
    @vfyw = Photo.instagram_tag_recent_media({:tag => "vfyw"}).first
  end

end
