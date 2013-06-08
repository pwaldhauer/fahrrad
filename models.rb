require 'rubygems'
require 'data_mapper'

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///data.db")

# Thats a bit messy, but hey.
class Tweet
	include DataMapper::Resource

	property :id, Serial
    property :tweet_id, String
	property :favs, Integer
	property :total_km, Float
	property :last_update, DateTime

end

class Trip
    include DataMapper::Resource

	property :id, Serial
	property :date, DateTime
    property :duration, Integer
	property :uri, String
	property :km, Float

end

DataMapper.finalize.auto_upgrade!
