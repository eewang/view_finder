module Locatable

  module InstanceMethods

    # => What are my coordinates?
    def coordinates
      [self.latitude, self.longitude]
    end

    def set_coordinates(lat, lon)
      self.latitude = lat
      self.longitude = lon
    end

    # => convert address to coords
    def address_to_coordinates
      query = Geocoder.search(self.street_address)
      query_lat = query[0].latitude
      query_lon = query[0].longitude
      self.set_coordinates(query_lat, query_lon)
    end

    # => convert coords to address
    def coordinates_to_address
      unless self.latitude.nil? || self.longitude.nil?
        Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
      end
    end

    def has_valid_location?
      true unless Geocoder.search(self.street_address).empty?
    end
    
    # def generate_street_address
    #   unless self.latitude.nil? || self.longitude.nil?
    #     Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
    #   end
    # end

    def distance_from_target_in_feet(target)
      self.distance_from_target_in_miles(target) * 5280
    end

    def distance_from_target_in_miles(target)
      if target.is_a?(Photo)
        target_coordinates = target.coordinates
      else
        target_coordinates = target
      end
      Geocoder::Calculations.distance_between(self.coordinates, target_coordinates)
    end

  end

  # module ClassMethods
  #   def nearby(center, radius)
  #     self.near(center, radius)
  #   end
  # end

end



