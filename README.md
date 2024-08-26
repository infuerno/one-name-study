## Getting started

1. Use compatible ruby environment either via rbenv or docker with an appropriate ruby image
   - e.g. `docker run -it -v $PWD:/code --name ruby334 ruby:3.3.4 bash`
   - surround $PWD with backticks on windows OR replace with `pwd -W` surrounded with backticks
2. `cd /code`
3. Edit `Gemfile` to have correct ruby version if upgrading
4. `bundle install`
5. Create `config/environment.rb` from example and enter values for vars

## Certificate errors

### Resolve for curl

1. Get CA cert: `openssl s_client -host www.gro.gov.uk -port 443`
2. Add to the bottom of `/etc/ssl/certs/ca-certificates.crt`

### Resolve for ruby

TODO

## Running tests

1. Run all tests: `bundle exec rspec`
2. Run single file: `bundle exec rspec spec/gro_births_extractor_spec.rb`
3. Run single test: `bundle exec rspec spec/gro_births_extractor_spec.rb:113` (e.g.for a test on line 113)

## Adhoc script

1. Update parameters in script
2. Run script: `ruby scripts/adhoc.rb`
3. Results will be saved in "results" directory with filename `surname_datetime.csv`


## TODO

1. Sort results
2. Allow "both" male and female searches
3. Tests for various search years and GRO references

