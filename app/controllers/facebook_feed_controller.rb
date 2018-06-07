require 'uri'
class FacebookFeedController < ApplicationController

  # Specify cache path since we serve this action from two different routes
  caches_action :show, cache_path: Proc.new { params[:facebook_page_id] }, expires_in: 12.hours

  def show
    page_id = params[:facebook_page_id] || (not_found and return)

    unless data = api_down_response
      fields = ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"]
      facebook_feed_uri = URI.encode("https://graph.facebook.com/v2.12/#{page_id}/posts?access_token=#{ENV['FACEBOOK_APP_ID']}|#{ENV['FACEBOOK_APP_SECRET']}&fields=#{fields.join(',')}")
      response = HTTParty.get(facebook_feed_uri)
      data = response.parsed_response
    end

    render json: data
  end

  private

  def api_down_response
    return false unless ENV['FACEBOOK_DOWN']
    { data: [ { id: "1",
                message: "The Facebook API is currently down. Please try again later",
                from: { id: "", name: "" }
              }
            ]
    }
  end
end
