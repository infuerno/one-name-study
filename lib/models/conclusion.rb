# id is string
# sources is [] of SourceReference
class Conclusion
  attr_reader :id, :sources
  def initialize(id, sources=[])
    @id = id,
    @sources = sources
  end
end
