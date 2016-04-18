require 'bundler'
Bundler.require
DB = SQLite3::Database.new('db/development.db')
DB.results_as_hash = true
