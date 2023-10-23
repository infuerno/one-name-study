
# Flags
# 0	Standard district
# 1	Alternative form of district
# 2	Misspelt alternative form of district
# 4	Currently unknown district
# 8	Volume disagrees with district
# 16	Date disagrees with district
# 32	Page outside range expected for district
# 64	Page range not checked (page uncertain)

Birth = Struct.new(:quarter, :year, :surname, :given_name, :mother, :district, :flag, :volume, :page) do
  def to_s
    "#{given_name},#{surname},#{mother},#{year},#{quarter},#{district},#{volume},#{page},#{flag}"
  end
end

Marriage = Struct.new(:quarter, :year, :surname, :given_name, :spouse, :district, :flag, :volume, :page) do
  def to_s
    "#{given_name},#{surname},#{spouse},#{year},#{quarter},#{district},#{volume},#{page},#{flag}"
  end
end

Death = Struct.new(:quarter, :year, :surname, :given_name, :spouse, :district, :flag, :volume, :page) do
  def to_s
    "#{given_name},#{surname},#{spouse},#{year},#{quarter},#{district},#{volume},#{page},#{flag}"
  end
end

def output_results(result_type, results)
  puts ""
  puts "***************"
  puts "*** #{result_type.upcase} ***"
  puts "***************"
  puts ""
  puts "Given Name\tSurname\tAAD/Spouse/Mother\tYear\tQuarter\tDistrict\tVolume\tPage\tFlag"
  results.each {|r| puts r.to_s}
end

births, marriages, deaths = [],[],[]
File.open("/Users/claire/Dropbox/Documents/Genealogy/Furney/ONS/freebmd-all.txt").readlines.each() do |line|
  cols = line.split("\t")
  case cols[0][/^\w+/]
    when "Births"
      birth = Birth.new(cols[1], cols[2], cols[3], cols[4], cols[5], cols[6], cols[7], cols[8], cols[9])
      births.push(birth)
    when "Marriages"
      marriage = Marriage.new(cols[1], cols[2], cols[3], cols[4], cols[5], cols[6], cols[7], cols[8], cols[9])
      marriages.push(marriage)
    when "Deaths"
      death = Death.new(cols[1], cols[2], cols[3], cols[4], cols[5], cols[6], cols[7], cols[8], cols[9])
      deaths.push(death)
  end
end

output_results("births", births)
output_results("marriages", marriages)
output_results("deaths", deaths)
