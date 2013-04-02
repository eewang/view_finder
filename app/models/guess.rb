class Guess < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :state, :street_address, :photo_id, :proximity_to_answer_in_feet

  belongs_to :user
  belongs_to :photo

  delegate :latitude, :longitude, :image, :user_name, :location, :guesses, :to => :photo, :prefix => true

  delegate :name, :email, :to => :user, :prefix => true

  include Locatable::InstanceMethods
  extend Locatable::ClassMethods

  geocoded_by :street_address
  after_validation :geocode

  def self.photo_guesses_sorted(photo)
    photo.guesses.sort_by { |g| g.proximity_to_answer_in_feet }
  end

  def set_attributes(params, guesser)
    # self.street_address = params[:guess][:street_address]
    self.photo = Photo.find_by_id(params[:guess][:photo_id])
    self.user = guesser
  end

  def distance_of_time_in_hours_and_minutes(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_hours   = (((to_time - from_time).abs) / 3600).round
    distance_in_minutes = ((((to_time - from_time).abs) % 3600) / 60).round

    difference_in_words = ''

    difference_in_words << "#{distance_in_hours} #{distance_in_hours > 1 ? 'hrs' : 'hr' } and " if distance_in_hours > 0
    difference_in_words << "#{distance_in_minutes} #{distance_in_minutes == 1 ? 'min' : 'mins' }"
  end

  def self.calculate_proximity
    self.all.each do |guess|
      guess.proximity_to_answer_in_feet = guess.distance_from_target_in_feet(guess.photo).round
      guess.save
    end
  end

end
