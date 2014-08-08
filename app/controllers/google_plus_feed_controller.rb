class GooglePlusFeedController < ApplicationController
  # caches_action :show, expires_in: 1.hour
  
  def show
    GooglePlus.api_key=ENV['GOOGLE_PLUS_API_KEY']
    page = GooglePlus::Person.get(params[:google_plus_page_id], user_ip: "216.228.180.219")
    feed = page.try(:list_activities).try(:items) || []
    render json: feed.to_json
  end
end
