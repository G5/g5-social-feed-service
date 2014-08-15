require 'rails_helper'

RSpec.describe FacebookFeedController, :type => :controller do
  it "Calls the Facebook Graph API with the correct params" do
    api_domain = 'https://graph.facebook.com'
    page_id = "1234567890"
    api_path = "posts"
    fields = ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"]
    access_token = "facebook-app-id%7Cfacebook-app-secret"
    response_json = double("response_json", :parsed_response => [])
    facebook_api_request = "#{api_domain}/#{page_id}/#{api_path}?access_token=#{access_token}&fields=#{fields.join(',')}"

    expect(HTTParty).to receive(:get).with(facebook_api_request).and_return(response_json)
    
    get :show, facebook_page_id: page_id
  end
end
