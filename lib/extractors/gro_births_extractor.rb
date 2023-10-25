class GroBirthsExtractor < GroExtractor
  Entry = Struct.new(:entry_id, :forenames, :surname, :mothers_maiden_name, :gender, :year, :quarter, :location, :volume, :page, :reference) do
    def to_s
      "#{entry_id},#{forenames},#{surname},#{mothers_maiden_name},#{gender},#{year},#{quarter},#{location},#{volume},#{page},#{reference}"
    end
  end

  def initialize(username, password, wait_between_requests = 2)
    super(username, password, wait_between_requests)
  end

  def get_search_type
    :birth
  end

  def get_entry(entry_id, forenames, surname, mothers_maiden_name, gender, year, quarter, location, volume, page, reference)
    Entry.new(entry_id, forenames, surname, mothers_maiden_name, gender, year, quarter, location, volume, page, reference)
  end

  def get_headers
    "entry_id,forenames,surname,mothers_maiden_name,gender,year,quarter,location,volume,page,reference"
  end
end