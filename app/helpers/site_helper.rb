module SiteHelper

  def location_game(photo, url)
    content_tag :div, :class => "item" do
      link_to image_tag(photo.image),
              url   
    end
  end

  def location_game_cover(image, url)
    content_tag :div, :class => "item active" do
      link_to image_tag(image), url
    end
  end

  def user_logged_in
    if current_user
      url = "auth/instagram"
    else
      url = login_path
    end
  end

  def user_feed(active = nil)
    if active
      content_tag :div, :class => "item active" do
        link_to(image_tag('introfriend1.jpg', {:width => 1000}),
                user_logged_in)
      end
    else
      content_tag :div, :class => "item" do
        link_to(image_tag('introfriend2.jpg', {:width => 1000}),
                user_logged_in)
      end
    end
  end

  def friend_feed_avatar(collection)
    link_to(image_tag(collection[2], :width => 600),
            :controller => "photos",
            :action => "friend_feed",
            :friend_name => collection[1])
  end

  def friend_feed_image(photo, array)
    link_to image_tag(photo.image),
            :controller => "photos",
            :action => "friend_feed",
            :friend_name => array[1]
  end

  def friend_feed_caption(collection)
    content_tag :div, :class => "carousel-caption" do
      content_tag :h4 do
        collection[1]
      end
    end
  end

  def intro_photos_carousel(photos_array)
    display_content = ""
    photos_array.each do |photo|
      display_content += content_tag :div, :class => "item #{photos_array.index(photo) == 0 ? 'active' : ''}" do
        image_tag photo
      end
    end
    raw display_content
  end

end
