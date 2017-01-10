require 'rails_helper'

RSpec.describe WalkscoreController, :type => :controller do
  before do
    controller.stub(:params).and_return({:address=>"201 Wilshire Blvd Ste 102", :city=>"Santa Monica", :state=>"CA", :lat=>"34.0180307", :lon=>"-118.500053"})
  end

  let(:walkscore_client) {controller.params[:walkscore_client]}
  let(:walkscore_location) {controller.params[:walkscore_location]}

  it "returns a json response from Walkscore API" do
    #could mock out the response so it's not hitting a real service
    response = controller.walkscore_uri_method(walkscore_location)
    response.header['Content-Type'].should include 'application/json'
  end
end