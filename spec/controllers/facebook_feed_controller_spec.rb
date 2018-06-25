require 'rails_helper'

RSpec.describe FacebookFeedController, :type => :controller do

  let(:page_id) { "1234567890" }
  let(:facebook_feed) { double :feed_object }

  it "Calls the Facebook Feed class" do
    expect(FacebookFeed).to receive(:new).with(page_id) { facebook_feed }
    expect(facebook_feed).to receive(:fetch_from_cache_or_api)
    get :show, params: {facebook_page_id: page_id}
  end

  it "404's if facebook_page_id is not provided" do
    get :show
    expect(response.body).to eq "404 not found"
    expect(response.status).to be(404)
  end
end
