# names is Name[]
class PlaceDescription < Subject
  attr_reader :names, :type, :place, :jurisdiction, :latitude, :longitude
  def initialize(names, type, place, jurisdiction=nil, latitude=nil, longitude=nil)
    @names = names,
    @type = type,
    @place = place,
    @jurisdiction = jurisdiction,
    @latitude = latitude,
    @longitude = longitude
  end
end
