require 'rails_helper'

RSpec.describe WalkscoreController, :type => :controller do
  before do 
    controller.stub(:params).and_return({:walkscore_client => "g5-c-1t2d31r8-berkshire-communities", :walkscore_location => "g5-cl-i2nmuhcd-thorncroft-farms"})
  end

  let(:walkscore_client) {controller.params[:walkscore_client]}
  let(:walkscore_location) {controller.params[:walkscore_location]}

  it "Calls the G5-Hub API given a Client & Location URN from Params and returns some JSON" do
    #could mock out the response so it's not hitting a real service
    response = controller.walkscore_hub_info(walkscore_client, walkscore_location)
    response.header['Content-Type'].should include 'application/json'
  end

  it "returns a json response from Walkscore API" do
    #could mock out the response so it's not hitting a real service
    response = controller.walkscore_uri_method(walkscore_client, walkscore_location)
    response.header['Content-Type'].should include 'application/json'
  end
end