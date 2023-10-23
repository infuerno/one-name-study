# name will depend on what is being qualified
# for Fact it is one of :age, i.e. age of the person at the event described by the fact, :cause e.g. cause of death, :religion e.g. religion of baptism
class Qualifier
  attr_reader :name, :value
  def initialize(name, value)
    @name = name,
    @value = value
  end
end