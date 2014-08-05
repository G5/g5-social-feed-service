class TwitterFeedController < ApplicationController
  caches_action :show, expires_in: 2.minutes

  def show
    twitter_handle = params[:handle]

    config = {
      :consumer_key    => ENV['TWITTER_CONSUMER_KEY'],
      :consumer_secret => ENV['TWITTER_CONSUMER_SECRET']
    }

    client = Twitter::REST::Client.new(config)
    options = {:count => 5, :include_rts => true}
    twitter_feed = client.user_timeline(twitter_handle, options)

    render json: twitter_feed
  end
end
