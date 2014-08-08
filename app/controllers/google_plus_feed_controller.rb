class GooglePlusFeedController < ApplicationController
  caches_action :show, expires_in: 1.hour
  
  def show
    GooglePlus.api_key=ENV['GOOGLE_PLUS_API_KEY']
    page = GooglePlus::Person.get(params[:google_plus_page_id])
    google_plus_feed = page.list_activities.items
    render json: google_plus_feed.to_json
  end
end
