class InstagramFeedController < ApplicationController
  caches_action :show, expires_in: 1.hour

  # The instagram user id is NOT the username -- it will be a numeric code
  # You can find this by going here https://smashballoon.com/instagram-feed/find-instagram-user-id/
  # or you can go to the users page and root around the page source and figure it out (do a find on  "id:")

  def show
    instagram_id = params[:instagram_id]
    instagram_number_of_photos = params[:instagram_number_of_photos]
    instagram_feed_uri = URI.encode("https://api.instagram.com/v1/users/#{instagram_id}/media/recent/?access_token=#{ENV['INSTAGRAM_ACCESS_TOKEN']}&scope=public_content&count=#{instagram_number_of_photos}")
    instagram_feed = HTTParty.get(instagram_feed_uri)
    render json: instagram_feed
  end

end
