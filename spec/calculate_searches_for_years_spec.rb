require 'rspec'
require './lib/extractors/base_extractor'
require './lib/extractors/gro_extractor'

describe ".calculate_searches_for_years" do

  gro_extractor = GroExtractor.new '', ''

  it 'should do no searches from year greater than to year' do
    searches = gro_extractor.calculate_searches_for_years(1838, 1837)
    expect(searches).to eq([])
  end

  it 'should do 1 search for 1837 to 1837' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1837)
    expect(searches.count).to eq(1)
    expect(searches).to eq([[1837, 0]])
  end

  it 'should do 2 searches for 1837 to 1838' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1838)
    expect(searches.count).to eq(2)
    expect(searches).to eq([[1837, 0], [1838, 0]])
  end

  it 'should do 1 search for 1837 to 1839' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1839)
    expect(searches.count).to eq(1)
    expect(searches).to eq([[1838, 1]])
  end

  it 'should do 2 searches for 1837 to 1840' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1840)
    expect(searches.count).to eq(2)
    expect(searches).to eq([[1838, 1], [1840, 0]])
  end

  it 'should do 1 search for 1837 to 1841' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1841)
    expect(searches.count).to eq(1)
    expect(searches).to eq([[1839, 2]])
  end

  it 'should do 2 searches for 1837 to 1842' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1842)
    expect(searches.count).to eq(2)
    expect(searches).to eq([[1839, 2], [1842, 0]])
  end

  it 'should do 3 searches for 1837 to 1843' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1843)
    expect(searches.count).to eq(3)
    expect(searches).to eq([[1839, 2], [1842, 0], [1843, 0]])
  end

  it 'should do 2 searches for 1837 to 1844' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1844)
    expect(searches.count).to eq(2)
    expect(searches).to eq([[1839, 2], [1843, 1]])
  end

  it 'should do 3 searches for 1837 to 1845' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1845)
    expect(searches.count).to eq(3)
    expect(searches).to eq([[1839, 2], [1843, 1], [1845, 0]])
  end

  it 'should do 1 search for 1837 to 1846' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1846)
    expect(searches.count).to eq(1)
    expect(searches).to eq([[1842, 5]])
  end

  it 'should do 2 searches for 1837 to 1847' do
    searches = gro_extractor.calculate_searches_for_years(1837, 1847)
    expect(searches.count).to eq(2)
    expect(searches).to eq([[1842, 5], [1847, 0]])
  end
end
