require 'rails_helper'

RSpec.describe TwitterFeedController, :type => :controller do
  let(:config)     { {:consumer_key => ENV['TWITTER_CONSUMER_KEY'], :consumer_secret => ENV['TWITTER_CONSUMER_SECRET']} }
  let(:options)    { {:count => 10, :include_rts => true} }
  let(:api_object) { double("api_object") }

  it "Makes a request to the Twitter API with the correct Twitter handle and Environment variables" do
    Twitter::REST::Client.stub(:new).with(config) { api_object }

    expect(api_object).to receive(:user_timeline).with("hansolo", options)
    get :show, params: {handle: "hansolo"}
  end

  it "Forwards Twitter's response as json" do
    fake_data = {foo: "bar", gigity: "goo"}.to_json
    Twitter::REST::Client.stub(:new) { api_object }
    api_object.stub(:user_timeline) { fake_data }

    get :show, params: {handle: "hansolo"}
    expect(response.body).to eq(fake_data)
  end
end
