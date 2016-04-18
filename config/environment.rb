require 'bundler'
Bundler.require
DB = SQLite3::Database.new('db/development.db')
DB.results_as_hash = true
$: << '.'
require 'app/models/hacktive_record'

Dir['app/models/*.rb'].each {|file| require file}
