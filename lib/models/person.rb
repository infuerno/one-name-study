# gender is :male, :female or :unknown
# names is [] of Name
# facts is [] of Fact
class Person < Subject
  attr_reader :private, :gender, :names, :facts

  def initialize(id, sources=[], names, gender=:unknown, facts=nil, private=false)
    @names = names
    @gender = gender
    @facts = facts
    @private = private
    super(id, sources)
  end
end

# person:id
# create a redis hash which has a person:id (self assigned e.g. uk1) as key
# and then has the following fields:
# key: "names"; value: hset
# OR
# key: birth_name ( the name type ); value: hset



