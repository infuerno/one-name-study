require 'rspec'
require './lib/base_extractor'

describe BaseExtractor do

  it 'initialize called with base url should not error' do
      BaseExtractor.new "base url"
  end

  it 'mechanize is instantiated' do
    e = BaseExtractor.new "base url"
    expect(e.instance_variable_get(:@mechanize)).to be
  end
end