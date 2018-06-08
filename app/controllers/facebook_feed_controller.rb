require 'uri'
class FacebookFeedController < ApplicationController

  # Specify cache path since we serve this action from two different routes
  # caches_action :show, cache_path: Proc.new { params[:facebook_page_id] }, expires_in: 12.hours

  def show
    page_id = params[:facebook_page_id] || (not_found and return)
    data = FacebookFeed.new(page_id).fetch_from_cache_or_api

    render json: data
  end
end
