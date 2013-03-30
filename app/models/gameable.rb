module Gameable
# CLASS METHODS

# When a user clicks on an image on the landing page, the application does the following:
# => Searches the photos table for all images within [1000 m] of the target picked by the user

  def search(target, radius)
    self.near(target, radius)
  end

# => Filters out the results that the user has already guessed on

  def exclude_user_guessed(user)
    photo_set.search()
  end
  
# => Randomize the results

  def randomize
  end

# => Select 20 photos to display

  def game_display(target, user, radius, count)
    Photo.search(target, radius).exclude_user_guessed(user).randomize.limit(count)
  end

# => If the user has not guessed on less than 20 photos, go to Instagram to get more photos

  
# include a "most guessed" filter - assuming that the most guessed photos are probably the best photos to guess on
end