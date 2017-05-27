require 'rspec'
require './lib/base_extractor'
require './lib/gro_extractor'

describe GroExtractor do

  username = ''
  password = ''

  gro_extractor = GroExtractor.new username, password

  it 'should give ArgumentError when initialize called without params' do
    expect {
      GroExtractor.new
    }.to raise_error(ArgumentError)
  end

  it 'should not error when initialize called with params' do
    GroExtractor.new "username", "password"
  end

  it 'instance variables set in initialize' do
    expect(gro_extractor.instance_variable_get(:@username)).to eq(username)
    expect(gro_extractor.instance_variable_get(:@password)).to eq(password)
  end

  describe "when logged in" do
    menu_page = gro_extractor.login()

    it 'should get a page after login' do
      expect(menu_page).to be
    end

    it 'should get the menu page after login' do
      expect(menu_page.uri.path).to eq("/gro/content/certificates/menu.asp")
    end

    describe "when selecting gro search" do
      search_page = gro_extractor.select_search_gro_indexes(menu_page)

      it 'should get a page after selecting the gro search' do
        expect(search_page).to be
      end

      it 'should get the search page after selecting the gro search' do
        expect(search_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
      end
    end
  end
end