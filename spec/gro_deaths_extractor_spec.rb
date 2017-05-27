require 'rspec'
require './lib/base_extractor'
require './lib/gro_extractor'
require './lib/gro_deaths_extractor'

describe GroDeathsExtractor do

  username = ''
  password = ''

  extractor = GroDeathsExtractor.new username, password
  menu_page = extractor.login()
  search_gro_indexes_page = extractor.select_search_gro_indexes(menu_page)

  search_type = extractor.get_search_type

  it "should get deaths search type" do
    expect(search_type).to eq(:death)
  end

  describe "when selecting deaths search type" do
    search_deaths_page = extractor.select_search_type(search_gro_indexes_page, search_type)

    it 'should get a page after selecting the birth search type' do
      expect(search_deaths_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the search page after selecting the deaths search type' do
      expect(search_deaths_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the deaths search page after selecting the deaths search type' do
      expect(search_deaths_page.search("td[text()='Surname at Death:']").length).to eq(1)
    end
  end
end