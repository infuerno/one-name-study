require 'rspec'
require 'mechanize'
require './lib/extractors/base_extractor'

describe BaseExtractor do
  it 'mechanize is instantiated' do
    e = BaseExtractor.new "base url"
    expect(e.instance_variable_get(:@mechanize)).to be
  end

  it 'initialize called without wait should not error' do
    BaseExtractor.new
  end

  it 'initialize called with wait should not error' do
    BaseExtractor.new 5
  end

  it 'initialize called without wait should have default wait' do
    e = BaseExtractor.new
    expect(e.instance_variable_get(:@wait_between_requests)).to eq(2)
  end

  it 'initialize called with wait should have new wait' do
    e = BaseExtractor.new 5
    expect(e.instance_variable_get(:@wait_between_requests)).to eq(5)
  end
end