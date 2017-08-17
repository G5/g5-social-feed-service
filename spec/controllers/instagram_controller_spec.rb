require 'rails_helper'

RSpec.describe InstagramFeedController, :type => :controller do
  let (:instagram_id) {'123456789'}
  let (:instagram_number_of_photos) {10}
  let(:response_json) { double("response_json", :parsed_response => []) }

  it "calls the instagram api with the correct params" do
    ENV['INSTAGRAM_ACCESS_TOKEN'] = 'ILiveIDieILiveAgain'
    expect(HTTParty).to receive(:get).with("https://api.instagram.com/v1/users/123456789/media/recent/?access_token=ILiveIDieILiveAgain&scope=public_content&count=10").and_return(response_json)
    get :show, params: {instagram_id: instagram_id, instagram_number_of_photos: instagram_number_of_photos}
  end

end
