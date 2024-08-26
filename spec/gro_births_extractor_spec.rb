require 'rspec'
require './lib/extractors/base_extractor'
require './lib/extractors/gro_extractor'
require './lib/extractors/gro_births_extractor'
require './config/environment'

describe GroBirthsExtractor do
  NUMBER_HEADER_ROWS_IN_RESULTS = 5
  NUMBER_FOOTER_ROWS_IN_RESULTS = 3
  NUMBER_OF_HEADER_AND_FOOTER_ROWS = NUMBER_HEADER_ROWS_IN_RESULTS + NUMBER_FOOTER_ROWS_IN_RESULTS

  extractor = GroBirthsExtractor.new ENV['gro_username'], ENV['gro_password']
  extractor.login()

  it 'should get birth search type' do
    expect(extractor.get_search_type).to eq(:birth)
  end

  describe 'when selecting search type births' do
    search_page = extractor.go_to_search_page()

    it 'should get a page after selecting the birth search type' do
      expect(search_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the search page after selecting the birth search type' do
      expect(search_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    it 'should get the births search page after selecting the birth search type' do
      expect(search_page.search("td.main_text > strong[text()='When was the birth registered?']").length).to eq(1)
    end
  end

  describe 'when searching' do
    search_page = extractor.go_to_search_page()
    results_page = extractor.search(search_page, 'Furney', :male, 1837)

    it 'should get a page' do
      expect(results_page).to be
    end

    it 'should get the search indexes page' do
      expect(results_page.uri.path).to eq("/gro/content/certificates/indexes_search.asp")
    end

    describe '.get_results_rows' do

      describe "search with no results" do
        results_page = extractor.search(search_page, 'Furney', :male, 1837)
        results_rows = extractor.get_results_rows(results_page)
        it 'should get some results rows' do
          expect(results_rows).to be
        end

        it 'should get "no results" message' do
          expect(results_rows.count).to eq(NUMBER_HEADER_ROWS_IN_RESULTS)
          expect(results_rows.last.text.downcase).to eq("no matching results found")
        end

        describe ".get_results_stats" do
          results_count, current_page, page_count = extractor.get_results_stats(results_rows.last)
          it 'should get 0 results' do
            expect(results_count).to eq(0)
          end
        end
      end

      describe "search with 1 result" do
        results_page = extractor.search(search_page, 'Furney', :male, 1838)
        results_rows = extractor.get_results_rows(results_page)

        it 'should get some results rows' do
          expect(results_rows).to be
        end

        it 'should get 5 header and footer rows and 2 rows for the 1 result' do
          expected_number_results = 1
          expect(results_rows.count).to eq(NUMBER_OF_HEADER_AND_FOOTER_ROWS + expected_number_results * 2)
        end

        describe ".get_results_stats" do
          results_count, current_page, page_count = extractor.get_results_stats(results_rows[-1])
          it 'should get 1 result' do
            expect(results_count).to eq(1)
          end
          it 'should get be on page 1' do
            expect(current_page).to eq(1)
          end
          it 'should have total pages of 1' do
            expect(page_count).to eq(1)
          end
        end
      end

      describe "search with multiple results on a single page" do
        results_page = extractor.search(search_page, 'Furney', :female, 1838)
        results_rows = extractor.get_results_rows(results_page)

        it 'should get results rows' do
          expect(results_rows).to be
        end

        it 'should get 5 header and footer rows and 4 rows for the 2 results' do
          expected_number_results = 2
          expect(results_rows.count).to eq(NUMBER_OF_HEADER_AND_FOOTER_ROWS + expected_number_results * 2)
        end

        describe 'get_results_stats' do
          results_count, current_page, page_count = extractor.get_results_stats(results_rows[-1])
          it 'should get results_count of 2' do
            expect(results_count).to eq(2)
          end
          it 'should get current_page of 1' do
            expect(current_page).to eq(1)
          end
          it 'should have total pages of 1' do
            expect(page_count).to eq(1)
          end
        end
      end

      describe 'search with multiple results on multiple pages' do
        results_page = extractor.search(search_page, 'Smith', :male, 1837)
        results_rows = extractor.get_results_rows(results_page)

        it 'should get results rows' do
          expect(results_rows).to be
        end

        it 'should get 5 header and footer rows and 100 rows for the 50 results' do
          expected_number_results = 50
          expect(results_rows.count).to eq(NUMBER_OF_HEADER_AND_FOOTER_ROWS + expected_number_results * 2)
        end

        describe 'get_results_stats' do
          results_count, current_page, page_count = extractor.get_results_stats(results_rows[-1])
          it 'should get results_count of 250' do
            expect(results_count).to eq(250)
          end
          it 'should get current_page of 1' do
            expect(current_page).to eq(1)
          end
          it 'should have total pages of 5' do
            expect(page_count).to eq(5)
          end
        end
      end
    end
  end

  describe '.parse_results' do
    search_page = extractor.go_to_search_page()
    results_page = extractor.search(search_page, 'Furney', :male, 1838)
    results_rows = extractor.get_results_rows(results_page)
    it 'should get an entry for every result' do
      number_results = (results_rows.length - NUMBER_OF_HEADER_AND_FOOTER_ROWS) /2
      entries = extractor.parse_results(1838, :male, results_rows)
      expect(entries.length).to eq(number_results)
    end

    it 'should get a populated entry for a result' do
      entries = extractor.parse_results(1838, :male, results_rows)
      expect(entries[0].entry_id).to eq('1838.5T6E7381A7I3774E9CC02I4MFX1LR74E.1838.False')
      expect(entries[0].forenames).to eq('WILLIAM')
      expect(entries[0].surname).to eq('FURNEY')
      expect(entries[0].mothers_maiden_name).to eq('-')
      expect(entries[0].year).to eq('1838')
      expect(entries[0].quarter).to eq('J')
      expect(entries[0].location).to eq('SAINT GEORGE THE MARTYR SOUTHWARK')
      expect(entries[0].volume).to eq('04')
      expect(entries[0].page).to eq('137')
    end

    it 'should append entries if exisiting array passed' do
      entries = [1,2,3]
      previous_length_of_entries_array = entries.length
      number_results = (results_rows.length - NUMBER_OF_HEADER_AND_FOOTER_ROWS) / 2
      entries = extractor.parse_results(1838, :male, results_rows, entries)
      expect(entries.length).to eq(number_results + previous_length_of_entries_array)
    end
  end

  describe '.extract' do
    it 'should return empty array when no results' do
      entries = extractor.extract 'Furney', :male, 1837, 1837
      expect(entries).to be
      expect(entries.length).to eq(0)
    end
    it 'should return one entry when one result' do
      entries = extractor.extract 'Furney', :male, 1838, 1838
      expect(entries.length).to eq(1)
    end
    it 'should return multiple entries when multiple results' do
      entries = extractor.extract 'Smith', :male, 1837, 1837
      expect(entries.length).to eq(250)
    end
    it 'should return populated entries' do
      entries = extractor.extract 'Furney', :male, 1838, 1838
      expect(entries[0].entry_id).to eq('1838.5T6E7381A7I3774E9CC02I4MFX1LR74E.1838.False')
      expect(entries[0].forenames).to eq('WILLIAM')
      expect(entries[0].surname).to eq('FURNEY')
      expect(entries[0].mothers_maiden_name).to eq('-')
      expect(entries[0].year).to eq('1838')
      expect(entries[0].quarter).to eq('J')
      expect(entries[0].location).to eq('SAINT GEORGE THE MARTYR SOUTHWARK')
      expect(entries[0].volume).to eq('04')
      expect(entries[0].page).to eq('137')
    end
  end

end