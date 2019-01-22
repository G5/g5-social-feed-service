require 'uri'
class RssFeedController < ApplicationController

  def show
    feed_url = params[:feed_url] || (not_found and return)
    data = RssFeed.new(feed_url).as_json

    render json: data
  end
end