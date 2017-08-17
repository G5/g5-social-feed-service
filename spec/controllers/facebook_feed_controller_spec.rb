require 'rails_helper'

RSpec.describe FacebookFeedController, :type => :controller do

  let(:api_domain) { 'https://graph.facebook.com/v2.6' }
  let(:page_id) { "1234567890" }
  let(:api_path) { "posts" }
  let(:fields) { ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"] }
  let(:access_token) { "facebook-app-id%7Cfacebook-app-secret" }
  let(:response_json) { double("response_json", :parsed_response => []) }
  let(:facebook_api_request) { "#{api_domain}/#{page_id}/#{api_path}?access_token=#{access_token}&fields=#{fields.join(',')}" }

  it "Calls the Facebook Graph API with the correct params" do
    expect(HTTParty).to receive(:get).with(facebook_api_request).and_return(response_json)
    get :show, params: {facebook_page_id: page_id}
  end

  it "404's if facebook_page_id is not provided" do
    get :show
    expect(response.body).to eq "404 not found"
    expect(response.status).to be(404)
  end
end
