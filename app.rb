require 'rubygems'

#require 'sinatra'

require './models.rb'

require 'twitter'
require 'runkeeper'

date_start = Date.parse(ENV['DATE_START']);

def update_runkeeper
	user = Runkeeper.new(ENV['RUNKEEPER_TOKEN'])
	puts user.name

	activities = user.fitness_activities;

	activities['items'].each do |activity|
		# skip things older than 8. juni
		date = Date.parse(activity['start_time']);
		if date < date_start do
			next
		end

		obj = Trip.first_or_create(:uri => activity['uri']);
		obj.duration = activity['duration'];
		obj.km = activity['total_distance'];
		obj.date = activity['start_time']
		obj.save
	end
end

def update_twitter
	Twitter.configure do |config|
	  config.consumer_key = ENV['TWITTER_CONSUMER']
	  config.consumer_secret = ENV['TWITTER_SECRET']
	  config.oauth_token = ENV['TWITTER_TOKEN']
	  config.oauth_token_secret = ENV['TWITTER_TOKEN_SECRET']
	end

	tweet = Twitter.Tweets.status(ENV['TWITTER_TWEET'])

	obj = Tweet.first_or_create(:id => ENV['TWITTER_TWEET'])
	obj.favs = tweet.favorite_count
	obj.last_update = Time.now

	# sum up km and save
	total_km = 0
	Trip.all().each do |trip|
		total_km += trip.km
	end

	obj.total_km = total_km/1000
	obj.save
end

update_runkeeper
update_twitter