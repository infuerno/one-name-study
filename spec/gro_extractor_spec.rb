require 'rspec'
require './lib/base_extractor'
require './lib/gro_extractor'
require './lib/environment'

describe GroExtractor do

  gro_extractor = GroExtractor.new ENV['gro_username'], ENV['gro_password']

  it 'should give ArgumentError when initialize called without params' do
    expect {
      GroExtractor.new
    }.to raise_error(ArgumentError)
  end

  it 'should not error when initialize called with params' do
    GroExtractor.new "username", "password"
  end

  it 'instance variables set in initialize' do
    expect(gro_extractor.instance_variable_get(:@username)).to eq(ENV['gro_username'])
    expect(gro_extractor.instance_variable_get(:@password)).to eq(ENV['gro_password'])
  end

  describe "when login succeeded" do
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

  describe "when login failed" do
    gro_extractor_fail = GroExtractor.new 'not-exist', 'blank'
    page = gro_extractor_fail.login()
    it 'should get a page after login failure' do
      expect(page).to be
    end

    it 'should get the login page again' do
      expect(page.uri.path).to eq("/gro/content/certificates/login.asp")
    end

    it 'should get login failure message' do
      expect(page.search("div strong font[text()='Login Failed. Either your Email address and/or Password are incorrect']").length).to eq(1)
    end

  end
end