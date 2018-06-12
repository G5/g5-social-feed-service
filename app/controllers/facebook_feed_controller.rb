require 'uri'
class FacebookFeedController < ApplicationController

  def show
    page_id = params[:facebook_page_id] || (not_found and return)
    data = FacebookFeed.new(page_id).fetch_from_cache_or_api

    render json: data
  end
end
