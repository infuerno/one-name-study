## Getting started

1. Use compatible ruby environment either via rbenv or docker with an appropriate ruby image
   - e.g. `docker run -it -v $PWD:/code --name ruby263 ruby:2.6.3 bash`
2. `bundle install`

## Running tests

1. Run all tests: `bundle exec rspec`
2. Run single test file: `bundle exec rspec spec/gro_births_extractor_spec.rb`
3. Run single test: `bundle exec rspec spec/gro_births_extractor_spec.rb:113` (for the test on line 113)

## Adhoc script


