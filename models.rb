require 'rubygems'
require 'data_mapper'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_TEAL_URL'] || "sqlite://test.db")


# Thats a bit messy, but hey.
class Tweet
	include DataMapper::Resource

	property :id, String
	property :favs, Integer
	property :total_km, Float
	property :last_update, DateTime

end

class Trip

	property :id, Serial
	property :date, DateTime
	property :uri, String
	property :km, Float

end

DataMapper.finalize.auto_upgrade!