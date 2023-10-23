# An "event" is an occurrence that happened at a specific time or period of time, often at a specific place or set of places.
# Events are often described by referencing people that played a role in that event
# Events infer relationships, but are independent
# A "fact" is something presumbed to be true about e.g. a person or a relationship
# Events are often used to infer facts
# type is usually one of :adoption, :birth, :burial, :census, :christening, :death, :divorce, :marriage
# Full list here: https://github.com/FamilySearch/gedcomx/blob/master/specifications/event-types-specification.md
class Event < Subject
  attr_reader :type, :date, :place, :roles

end

class EventRole

end

