# type is usually one of :adoption, :birth, :burial, :christening, :death, :residence, :divorce, :marriage
# Full list here: https://github.com/FamilySearch/gedcomx/blob/master/specifications/fact-types-specification.md
# place is PlaceReference

class Fact < Conclusion
  attr_reader :type, :date, :place, :value
  def initialize(type, date, place, value, qualifiers)
    @type = type,
    @date = date,
    @place = place,
    @value = value,
    @qualifiers = qualifiers
  end
end