require 'rspec'
require './lib/base_extractor'
require './lib/gro_extractor'
require './lib/gro_births_extractor'

describe GroBirthsExtractor do

  username = ''
  password = ''

  extractor = GroBirthsExtractor.new username, password
  menu_page = extractor.login()
  search_gro_indexes_page = extractor.select_search_gro_indexes(menu_page)

  search_type = extractor.get_search_type

  it "should get birth search type" do
    expect(search_type).to eq(:birth)
  end

  describe "when selecting search type births" do
    search_page = extractor.select_search_type(search_gro_indexes_page, search_type)

    it 'should get a page after selecting the birth search type' do
      expect(search_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the search page after selecting the birth search type' do
      expect(search_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the births search page after selecting the birth search type' do
      expect(search_page.search("td[text()='Surname at Birth:']").length).to eq(1)
    end

    describe "when searching" do
      results_page = extractor.search(search_page, 'Furney', :male, 1837)

      it 'should get a page' do
        expect(results_page).to be
      end

      it 'should get the search indexes page' do
        expect(results_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
      end

      describe ".get_results_rows" do

        describe "search with no results" do
          results_page = extractor.search(search_page, 'Furney', :male, 1837)
          results_rows = extractor.get_results_rows(results_page)
          it 'should get results rows' do
            expect(results_rows).to be
          end

          it 'should get text only rows' do
            expect(results_rows.count).to eq(2)
          end

          # TODO check for No Results
        end

        describe "search with one result" do
          results_page = extractor.search(search_page, 'Furney', :male, 1838)

          it 'should get results rows' do
            results_rows = extractor.get_results_rows(results_page)
            expect(results_rows).to be
          end

          it 'should get 5 header and footer rows and 2 rows for the result' do
            expected_number_results = 1
            number_header_and_footer_rows = 5
            results_rows = extractor.get_results_rows(results_page)
            expect(results_rows.count).to eq(number_header_and_footer_rows + expected_number_results * 2)
          end
        end
      end
    end

  end
end