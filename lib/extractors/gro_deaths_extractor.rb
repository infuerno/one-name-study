class GroDeathsExtractor < GroExtractor
  def initialize(username, password, wait_between_requests = 2)
    super(username, password, wait_between_requests)
  end

  def get_search_type
    :death
  end
end