module PhotosHelper

  def route(photo, user)
    photo.guessed_by?(user) ? "guesses" : "photos"
  end

  def link(photo, user)
    photo.guessed_by?(user) ? photo.guesses.where(:user_id => user.id).first.id : photo.game
  end

  def method(photo, user)
    photo.guessed_by?(user) ? "GET" : "POST"
  end

  def view_play(photo, user)
    if photo.guessed_by?(user)
      link_to("VIEW", 
              "/#{route(photo, user)}/#{link(photo, user)}",
              :class => "styled-button-5 view_play_button")
    else
      submit_tag("PLAY",
                :class => "styled-button-5 view_play_button",
                :data => {
                  :photo => photo.id
                  })
    end
  end

end
