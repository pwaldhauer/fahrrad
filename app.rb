require 'rubygems'
require 'erb'

require './models.rb'

require 'twitter'
require 'runkeeper'

require 'dotenv'
Dotenv.load

@date_start = Date.parse(ENV['DATE_START']);

def update_runkeeper
	user = Runkeeper.new(ENV['RUNKEEPER_TOKEN'])

	activities = user.fitness_activities;

	activities['items'].each do |activity|
		# skip things older than 8. juni
		date = Date.parse(activity['start_time']);
		next if (date < @date_start)

		uri = activity['uri'][/\d+$/]

		obj = Trip.first_or_create(:uri => uri);
		obj.duration = activity['duration'];
		obj.km = activity['total_distance'];
		obj.date = date
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

	tweet = Twitter.status(ENV['TWITTER_TWEET'])

	obj = Tweet.first_or_create(:tweet_id => ENV['TWITTER_TWEET'])
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

def render_template
	obj = Tweet.first_or_create(:tweet_id => ENV['TWITTER_TWEET'])

	@km_left = (obj.favs - obj.total_km).round
	@km_percent = (obj.total_km/obj.favs) * 100

	@trips = Trip.all(:order => [ :date.desc ])

	renderer = ERB.new(File.read('template.erb'));
	output = renderer.result();

	File.open('index.html', 'w') do |f|
	      f.write(output)
	end
end

update_runkeeper

update_twitter

render_template

