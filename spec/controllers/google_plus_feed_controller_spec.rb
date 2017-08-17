require 'rails_helper'

RSpec.describe GooglePlusFeedController, :type => :controller do
  before do
    @google_plus_object = Object.new
    @page_id = "1234567890"
  end

  it "Initializes the GooglePlus API with the correct params" do
    expect(GooglePlus::Person).to receive(:get).with(@page_id)
    get :show, params: {google_plus_page_id: @page_id}
  end

  it "Passes on the Google Plus data as json" do
    GooglePlus::Person.stub(:get).and_return(@google_plus_object)
    fake_data = {foo: "bar", gigity: "goo"}
    @google_plus_object.stub_chain(:list_activities, :items).and_return(fake_data)

    get :show, params: {google_plus_page_id: @page_id}
    expect(response.body).to eq(fake_data.to_json)
  end

  it "Returns empty json on bad requests" do
    GooglePlus::Person.stub(:get).and_return(@google_plus_object)

    get :show, params: {google_plus_page_id: "bad-page-id"}
    expect(response.body).to eq("[]")
  end
end
