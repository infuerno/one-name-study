require 'rspec'
require './lib/extractors/base_extractor'
require './lib/extractors/gro_extractor'
require './lib/extractors/gro_deaths_extractor'
require './config/environment'

describe GroDeathsExtractor do

  extractor = GroDeathsExtractor.new ENV['gro_username'], ENV['gro_password']
  extractor.login()

  it "should get deaths search type" do
    expect(extractor.get_search_type).to eq(:death)
  end

  describe "when selecting deaths search type" do
    search_deaths_page = extractor.go_to_search_page()

    it 'should get a page after selecting the birth search type' do
      expect(search_deaths_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the search page after selecting the deaths search type' do
      expect(search_deaths_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the deaths search page after selecting the deaths search type' do
      expect(search_deaths_page.search("td.main_text > strong[text()='When was the death registered?']").length).to eq(1)
    end
  end
end