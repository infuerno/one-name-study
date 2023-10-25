require 'mechanize'
require 'nokogiri'
require 'json'
require 'net/http'

require './lib/extractors/base_extractor'

class GroExtractor < BaseExtractor
  BASE_URL = 'https://www.gro.gov.uk'
  LOGIN_PAGE_URL = BASE_URL + '/gro/content/certificates/Login.asp'
  USAGE_POLICIES_PAGE_URL = BASE_URL + '/gro/content/certificates/usage_policies.asp'
  SEARCH_PAGE_URL = BASE_URL + '/gro/content/certificates/indexes_search.asp'
  MENU_PAGE_URL = BASE_URL + '/gro/content/certificates/menu.asp'
  NUMBER_OF_HEADER_AND_FOOTER_ROWS = 8
  NBSP = Nokogiri::HTML("&nbsp;").text

  def initialize(username, password, wait_between_requests = 2)
    @username = username
    @password = password

    super(wait_between_requests)
  end

  def login
    if (@menu_page) then return @menu_page end

    puts 'Logging in ...'
    page_after_login = @mechanize.get(LOGIN_PAGE_URL).form_with :action => 'login.asp' do |form|
      form.username = @username
      form.password = @password
    end.click_button

    case page_after_login.uri.path
      when '/gro/content/certificates/login.asp'
        puts "Login not successful"
        @failed_login_page = page_after_login
      when '/gro/content/certificates/usage_policies.asp'
        @menu_page = accept_terms()
      when '/gro/content/certificates/menu.asp'
        @menu_page = page_after_login
      else
        raise "Unexpected page, expecting #{MENU_PAGE_URL}, got #{page_after_login.uri.path}" unless page_after_login.uri.path == '/gro/content/certificates/menu.asp'
    end
  end

  # private, called by login IF presented
  def accept_terms
    puts 'Accepting terms and conditions ... [completely untested - you may just wish to accept them manually!!]'
    @menu_page = @usage_policies_page.form_with :action => 'usage_policies.asp' do |form|
      form.Accepted = true
    end.click_button
    raise "Unexpected page, expecting #{MENU_PAGE_URL}, got #{@menu_page.uri.path}" unless @menu_page.uri.path == '/gro/content/certificates/usage_policies.asp'
  end

  def go_to_search_page
    if (@search_page) then return @search_page end

    raise RuntimeError "Please login before navigating to search page" if not @menu_page

    search_type_select_page = select_search_gro_indexes()
    @search_page = select_search_type(search_type_select_page, get_search_type)
  end

  # private, called by go_to_search_page
  def select_search_gro_indexes
    raise RuntimeError "Please ensure there is a menu page before trying to navigate to the GRO Indexes" if not @menu_page

    @mechanize.click(@menu_page.link_with(:text => /GRO Indexes/))
  end

  # private, called by go_to_search_page
  def select_search_type(page, type)
    puts "Selecting search type: #{type} ..."
    page.form_with('SearchIndexes') do |form|
      form.radiobutton_with(:value => type == :death ? 'EW_Death' : 'EW_Birth').check
    end.click_button
  end

  # private, called by go_to_search_page
  def get_search_type
    raise NotImplementedError.new("You must implement 'get_search_type' in the derived class.")
  end

  def extract(surname, gender, from=1837, to=1916)
    searches = calculate_searches_for_years(from, to)
    entries = Array.new
    searches.each do |year, range|
      sleep @wait_between_requests
      results_page = search(@search_page, surname, gender, year, range)
      results_rows = get_results_rows(results_page)
      results_count, current_page, page_count = get_results_stats(results_rows[-1])

      if results_count == 0 then
        puts "No matching results found, continuing with next search in batch"
        next
      end

      puts "Parsing results for page: #{current_page} of #{page_count}"
      entries = parse_results(year, gender, results_rows, entries)

      # get the next page if multiple pages
      while current_page < page_count
        puts "On page #{current_page} out of #{page_count}, getting next one..."
        sleep @wait_between_requests # pause 2 seconds so as not to overload the server
        results_page.form_with('SearchIndexes') do |form|
          results_page = form.submit(form.button_with(:value => 'Next Page')) # Next Page button
        end

        results_rows = get_results_rows(results_page)
        results_count, current_page, page_count = get_results_stats(results_rows[-1])
        puts "Parsing results for page: #{current_page} of #{page_count}"
        entries = parse_results(year, gender, results_rows, entries)
      end
    end
    entries
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
    puts "Searching with criteria: #{surname}, #{year}, #{gender}, #{range} ..."
    # initially only Year and Range are shown
    if (!page.respond_to?(:Surname))
      page = page.form_with('SearchIndexes') do |form|
        form.Year = year
        form.Range = range
      end.click_button
    end
    page.form_with('SearchIndexes') do |form|
      form.Year = year unless form.Year == year
      form.Range = range unless form.Range == range
      form.Surname = surname
      form.Gender = gender == :male ? 'M' : 'F'
    end.click_button
  end

  def check_table_heading(heading_row)
    # first row contains the header, second row contains the table headings (not needed)
    heading = heading_row.at_css('h3').text
    if !heading.start_with?('Results:')
      raise RuntimeError "No results table found, or header was not 'Results:' - check markup, NOT formatted as expected"
    end
  end

  def get_results_rows(page)
    doc = Nokogiri::HTML(page.body)
    results_table = doc.css('form table table table')[3]
    #pp results_table[3]
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

  def parse_results(search_year, gender, results_rows, entries=[])
    results_rows = remove_header_and_footer_rows(results_rows)

    # there are 2 rows for each result
    Array(0...results_rows.length).select {|i| i % 2 == 0 }.each do |i| # e.g for 3 results will give array 2,4,6

      count_info_output_size = 20
      if i % count_info_output_size == 0
        start_entry_index = (i / 2) + 1
        end_entry_index = (i + [results_rows.length - 2, count_info_output_size - 2].min)/2 + 1
        puts "Parsing results for entries: #{start_entry_index} to #{end_entry_index} of #{results_rows.length/2}" # rows 0,1 are for entry 1, rows 2,3 for entry 2, rows 4,5 for entry 3 etc
      end

      tds = results_rows[i].css('td')
      entry_id = tds[0].at_css('input > @id').value # e.g. 1838.5T6E7381A7I3774E9CC02I4MFX1LR74E.1838.False
      surname, forenames = tds[1].text.delete("\n\t\r").gsub(NBSP, ' ').split(',').collect {|s| s.strip}
      mothers_maiden_name = tds[2].text.delete("\n\t\r").gsub(NBSP, ' ').strip

      gro_reference = results_rows[i + 1].css('td text()')[1].text.delete("\n\t\r").gsub(NBSP, ' ').strip
      puts "Applying regex to: #{gro_reference}"

      if (search_year <= 1950) # slighly random ... allow leeway for 5 years range in search
        regex = /(\d{4}) ([MJSD]) Quarterin([\w&, \-\.\']+) Volume (\w+) Page (\w+)/
        year, quarter, location, volume, page = regex.match(gro_reference)[1..-1].collect{|s| s.strip.delete(',')}
      else
        regex = /DOR (Q[1234])\/(\d{4})in ([\w&, \-\.\'\/]+) \(([\w\-]+)\) (?:(Volume \w+ Page \w+|Reg \w+|Page 0 Reg \w+|)) ?(Entry Number \d+)/
        quarter, year, location, ref1, ref2, ref3 = regex.match(gro_reference)[1..-1].collect{|s| s == nil ? nil : s.strip.delete(',')}
        if (ref2 && ref2.start_with?("Volume"))
          volume, page = /Volume (\w+) Page (\w+)/.match(ref2)[1..-1].collect{|s| s == nil ? nil : s.strip.delete(',')}
          reference = "#{ref1} #{ref3}"
        else
          reference = "#{ref1} #{ref2} #{ref3}".gsub("  ", " ")
        end
      end
      entry = get_entry(entry_id, forenames, surname, mothers_maiden_name, gender, year, quarter, location, volume, page, reference)
      puts "Parsed entry: #{entry.to_s}"
      entries.push(entry)
    end
    entries
  end

  # 5 rows for the header and 3 rows for the footer
  def remove_header_and_footer_rows(results_rows)
    results_rows[5..-4]
  end
end


















