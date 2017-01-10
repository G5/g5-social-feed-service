class InstagramFeedController < ApplicationController
  caches_action :show, expires_in: 1.hour

  def show
    instagram_username = params[:instagram_user_id]
    instagram_number_of_photos = params[:instagram_number_of_photos] || 12
    access_token = "394214023.99e8186.675726e8aecc44b19c15b3845c03fd00"
    # https://api.instagram.com/v1/users/394214023/media/recent/?access_token=394214023.99e8186.675726e8aecc44b19c15b3845c03fd00&count=10
    instagram_feed_uri = URI.encode("https://api.instagram.com/v1/users/self/media/recent/?access_token=#{access_token}&count=#{instagram_number_of_photos}")
    instagram_feed = HTTParty.get(instagram_feed_uri)
    render json: instagram_feed

    # client_id =  " 99e8186908d44452aea51fc9bb953011"
    # client_secret = "8b41501037c64963ad90e2b40b69e479"
  end

end


# ↳ curl -F 'client_id=99e8186908d44452aea51fc9bb953011' \
# -F 'client_secret=8b41501037c64963ad90e2b40b69e479' \
# -F 'grant_type=authorization_code' \
#     -F 'redirect_uri=http://localhost:3000/' \
# -F 'code=805c8199d08e44409e04970cff47267e' \
# https://api.instagram.com/oauth/access_token
# {"user": {"profile_picture": "https://scontent.cdninstagram.com/t51.2885-19/s150x150/13408912_534041490121117_1590437116_a.jpg", "username": "gonesurfing541", "website": "", "id": "394214023", "bio": "", "full_name": "Matt Bishop"}, "access_token": "394214023.99e8186.675726e8aecc44b19c15b3845c03fd00"}%

# https://api.instagram.com/v1/users/394214023/media/recent/?access_token=394214023.99e8186.675726e8aecc44b19c15b3845c03fd00&count=10
# https://api.instagram.com/v1/users/self/media/recent/?access_token=394214023.99e8186.675726e8aecc44b19c15b3845c03fd00