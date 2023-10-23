# type is :couple or :parent_child
# person1, person2 is Person
# facts is Fact[]
class Relationship < Subject
  attr_reader :type, :person1, :person2, :facts
  def initialize(type, person1, person2, facts=nil)
    @type = type
    @person1 = person1
    @person2 = person2
    @facts = facts
  end
end