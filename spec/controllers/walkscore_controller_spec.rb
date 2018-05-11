require 'rails_helper'

#mock request to walkscore API
RSpec.configure do |config|
    config.before(:each) do
      stub_request(:get, /api.walkscore.com/).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(
          :status => 200,
          :headers => {"Content-Type"=> "application/json"})
    end
end

RSpec.describe WalkscoreController, :type => :controller do
  before do
    controller.stub(:params).and_return({:address=>"201 Wilshire Blvd Ste 102", :city=>"Santa Monica", :state=>"CA", :lat=>"34.0180307", :lon=>"-118.500053"})
  end

  let(:walkscore_client) {controller.params[:walkscore_client]}
  let(:walkscore_location) {controller.params[:walkscore_location]}

end
