require 'rubygems'
require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :host => "localhost",
  :username => "username",
  :password => "password",
  :database => "database"
)

