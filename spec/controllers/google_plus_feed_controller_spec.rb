require 'rails_helper'

RSpec.describe GooglePlusFeedController, :type => :controller do
  before do
    @google_plus_object = Object.new
    @page_id = "1234567890"
  end

  it "Returns empty json until all the sites have been deployed" do
    get :show, params: {google_plus_page_id: "whatever"}
    expect(response.body).to eq("[]")
  end
end
