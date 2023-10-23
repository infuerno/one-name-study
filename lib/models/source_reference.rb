# description is URI, foreign key to SourceDescription.id
class SourceReference

  attr_reader :description, :description_id, :attribution

  def initialize(description, description_id, attribution)
    @description = description,
    @description_id = description_id,
    @attribution = attribution
  end

end