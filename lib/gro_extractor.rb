require 'mechanize'
require 'nokogiri'
require 'json'
require 'net/http'


class GroExtractor < BaseExtractor
  BASE_URL = 'https://www.gro.gov.uk'
  LOGIN_PAGE_URL = BASE_URL + '/gro/content/certificates/Login.asp'
  SEARCH_PAGE_URL = BASE_URL + '/gro/content/certificates/indexes_search.asp'
  NUMBER_OF_HEADER_AND_FOOTER_ROWS = 5
  NBSP = Nokogiri::HTML("&nbsp;").text

  def initialize(username, password, wait_between_requests = 2)
    @username = username
    @password = password

    super(wait_between_requests)
  end

  def extract(surname, gender, from=1837, to=1916)
    menu_page = login()
    search_type_select_page = select_search_gro_indexes(menu_page)
    search_page = select_search_type(search_type_select_page, get_search_type)
    searches = calculate_searches_for_years(from, to)
    entries = Array.new
    searches.each do |year, range|
      sleep @wait_between_requests
      page = search(page, surname, gender, year, range)

      results_rows = get_results_rows(page)
      results_count, current_page, page_count = get_results_stats(results_rows[-1])

      if results_count == 0 then
        puts "No matching results found"
        next
      end

      puts "Parsing results for page: #{current_page} of #{page_count}"
      entries = parse_results(results_rows[2..-4], entries)

      while current_page < page_count
        puts 'More pages, getting next one...'
        sleep @wait_between_requests # pause 2 seconds so as not to overload the server
        page.form_with('SearchIndexes') do |form|
          page = form.submit(form.button_with(:value => 'Next Page')) # Next Page button
        end

        results_rows = get_results_rows(page)
        results_count, current_page, page_count = get_results_stats(results_rows[-1])
        puts "Parsing results for page: #{current_page} of #{page_count}"
        entries = parse_results(results_rows[2..-4], entries)
      end
    end
    entries
  end

  def login
    puts 'Logging in ...'
    @mechanize.get(LOGIN_PAGE_URL).form_with :action => 'login.asp' do |form|
      form.username = @username
      form.password = @password
    end.click_button
  end

  def select_search_gro_indexes(menu_page)
    @mechanize.click(menu_page.link_with(:text => /Search the GRO Indexes/))
  end

  def get_search_type
    raise NotImplementedError.new("You must implement 'get_search_type'.")
  end

  def select_search_type(page, type)
    puts "Selecting search type: #{type} ..."
    page.form_with('SearchIndexes') do |form|
      form.radiobutton_with(:value => type == :death ? 'EW_Death' : 'EW_Birth').check
    end.click_button
  end

  # its possible to seach for range of 0, 1, 2 or 5 years
  # use minimum numbers of searches to get exactly the range required
  def calculate_searches_for_years(from, to)
    case to - from
      when -1
        []
      when 0,1
        [[from, 0]] + calculate_searches_for_years(from + 1, to)
      when 2,3
        [[from + 1, 1]] + calculate_searches_for_years(from + 3, to)
      when 4,5,6,7,8
        [[from + 2, 2]] + calculate_searches_for_years(from + 5, to)
      else
        [[from + 5, 5]] + calculate_searches_for_years(from + 10, to)
    end
  end

  def search(page, surname, gender, year, range=0)
    puts "Searching with criteria: #{surname}, #{year}, #{gender} ..."
    page.form_with('SearchIndexes') do |form|
      form.Surname = surname
      form.Gender = gender == :male ? 'M' : 'F'
      form.Year = year
      form.Range = range
    end.click_button
  end

  def check_table_heading(heading_row)
    # first row contains the header, second row contains the table headings (not needed)
    heading = heading_row.at_css('h3').text
    if heading != 'Results:'
      raise RuntimeError "No results table found, or header was not 'Results:' - check markup, NOT formatted as expected"
    end
  end

  def get_results_rows(page)
    doc = Nokogiri::HTML(page.body)
    results_table = doc.css('form table table table')[3]
    results_rows = results_table.css('tr')
    check_table_heading(results_rows[0])
    results_rows
  end

  def get_results_stats(footer_row)
    number_of_results_info = footer_row.text.strip
    if number_of_results_info == "No Matching Results Found"
      [0,0,0]
    else
      /(\d+) Record\(s\) Found - Showing Page (\d+) of (\d+)/.match(number_of_results_info)[1..-1].collect{|s| s.to_i}
    end
  end

  def parse_results(results_rows, entries)
    # there are 2 rows for each result, starting on the third row
    Array(0...results_rows.length).select {|i| i % 2 == 0 }.each do |i| # e.g for 3 results will give array 2,4,6

      count_info_output_size = 20
      if i % count_info_output_size == 0
        start_entry_index = (i / 2) + 1
        end_entry_index = (i + [results_rows.length - 2, count_info_output_size - 2].min)/2 + 1
        puts "Parsing results for entries: #{start_entry_index} to #{end_entry_index} of #{results_rows.length/2}" # rows 0,1 are for entry 1, rows 2,3 for entry 2, rows 4,5 for entry 3 etc
      end

      tds = results_rows[i].css('td')
      surname, forenames = tds[0].text.delete("\n\t\r").gsub(NBSP, ' ').split(',').collect {|s| s.strip}
      mothers_maiden_name = tds[1].text.delete("\n\t\r").gsub(NBSP, ' ').strip

      gro_reference = results_rows[i + 1].text.delete("\n\t\r").gsub(NBSP, ' ').strip
      year, quarter, location, volume, page = /GRO Reference:(\d+) ([MJSD]) Quarterin([A-Z\-\.\', ]+) Volume (\w+) Page (\w+)/.match(gro_reference)[1..-1].collect{|s| s.strip.delete(',')}
      entry = get_entry(i, surname, forenames, mothers_maiden_name, year, quarter, location, volume, page)
      puts "Parsed entry: #{entry.to_s}"
      entries.push(entry)
    end
    entries
  end

end


















