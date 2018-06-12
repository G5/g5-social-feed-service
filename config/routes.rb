Rails.application.routes.draw do
  root 'api_status#index'

  get 'google-plus-feed/:google_plus_page_id' => 'google_plus_feed#show'

  get 'twitter-feed/:handle' => 'twitter_feed#show'

  get 'facebook-feed/:facebook_page_id' => 'facebook_feed#show'
  get 'facebook-feed' => 'facebook_feed#show'
  get 'instagram-feed' => 'instagram_feed#show'
  get 'walkscore-params/:walkscore_client' => 'walkscore#show'
end
