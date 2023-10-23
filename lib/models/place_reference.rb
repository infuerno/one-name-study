# original is string, the original place name text
# description_ref is PlaceDescription
class PlaceReference
  attr_reader :original, :description_ref
  def initialize(original, discription_ref)
    @original = original
    @description_ref = description_ref
  end
end