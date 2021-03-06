class GroBirthsExtractor < GroExtractor
  Entry = Struct.new(:entry_id, :forenames, :surname, :mothers_maiden_name, :year, :quarter, :location, :volume, :page) do
    def to_s
      "#{entry_id},#{forenames},#{surname},#{mothers_maiden_name},#{year},#{quarter},#{location},#{volume},#{page}"
    end
  end

  def initialize(username, password, wait_between_requests = 2)
    super(username, password, wait_between_requests)
  end

  def get_search_type
    :birth
  end

  def get_entry(entry_id, forenames, surname, mothers_maiden_name, year, quarter, location, volume, page)
    Entry.new(entry_id, forenames, surname, mothers_maiden_name, year, quarter, location, volume, page)
  end
end