require 'data_mapper'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

require File.dirname(__FILE__) + '/user'
require File.dirname(__FILE__) + '/auth'
require File.dirname(__FILE__) + '/task'
require File.dirname(__FILE__) + '/item'


DataMapper.finalize
# DataMapper.auto_migrate!