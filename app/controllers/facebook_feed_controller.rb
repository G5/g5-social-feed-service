require 'uri'
class FacebookFeedController < ApplicationController
  caches_action :show, expires_in: 30

  def show
    page_id = params[:facebook_page_id]

    # Should we hardcode these?
    fields = ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"]

    facebook_feed_uri = URI.encode("https://graph.facebook.com/#{page_id}/posts?access_token=#{ENV['FACEBOOK_APP_ID']}|#{ENV['FACEBOOK_APP_SECRET']}&fields=#{fields.join(',')}")
    response = HTTParty.get(facebook_feed_uri)

    render json: response.parsed_response
  end

end
