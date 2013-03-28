module Locatable

  def coordinates
    [self.latitude, self.longitude]
  end

  def set_coordinates(lat, lon)
    self.latitude = lat
    self.longitude = lon
  end

  def address_to_coordinates
    query = Geocoder.search(self.street_address)
    query_lat = query[0].latitude
    query_lon = query[0].longitude
    self.set_coordinates(query_lat, query_lon)
  end

  def coordinates_to_address
    unless self.latitude.nil?
      Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
    end
  end

  def has_valid_location?
    true unless Geocoder.search(self.street_address).empty?
  end
  
  def generate_street_address
    unless self.latitude.nil? || self.longitude.nil?
      Geocoder.search("#{self.latitude}, #{self.longitude}")[0].address
    end
  end

end



