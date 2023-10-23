require './lib/extractors/base_extractor'
require './lib/extractors/gro_extractor'
require './lib/extractors/gro_births_extractor'
require './config/environment'

extractor = GroBirthsExtractor.new ENV['gro_username'], ENV['gro_password']
extractor.login()
extractor.go_to_search_page()

surname = 'furney'
from = 1837
to = 1934 #Time.now.year
entries = extractor.extract surname, :male, from, to
entries += extractor.extract surname, :female, from, to

output = extractor.get_headers
output += entries.map { |entry| entry.to_s }.join("\n")

filename = "results/#{surname}_" + Time.now.to_s.delete("-: ")[0,14] + ".csv"
File.write(filename, output, mode: "a")

puts "Saved results to file #{filename}"