require 'spec_helper'

describe FacebookFeed do
  # Time represents when the feed was last pulled from the API and cached.
  let(:fresh_feed)    { { time: (Time.now - 3.hours),  data: "Feed cached 3 hours ago" }.to_json }
  let(:stale_feed)    { { time: (Time.now - 16.hours), data: "Feed cached 16 hours ago" }.to_json }

  # API Status expressed as a percentage of rate limit used.
  let(:underutilized_api)     { { time: (Time.now - 10.minutes), status: 15 }.to_json }
  let(:ideal_api_utilization) { { time: (Time.now - 10.minutes), status: 85 }.to_json }
  let(:overutilized_api)      { { time: (Time.now - 10.minutes), status: 99 }.to_json }
  let(:api_sitting_idle)      { { time: (Time.now - 61.minutes), status: 99 }.to_json }

  let(:api_domain)   { 'https://graph.facebook.com/v2.12' }
  let(:access_token) { "facebook-app-id%7Cfacebook-app-secret" }
  let(:fields)       { ["id", "from", "message", "picture", "link", "type", "created_time", "updated_time"] }
  let(:api_request)  { "#{api_domain}/#{page_id}/posts?access_token=#{access_token}&fields=#{fields.join(',')}" }

  let(:api_response) { double :api_response }
  let(:parsed_response) { { data: ["json data from facebook"] }.to_json }
  let(:response_headers) { { 'x-app-usage' => '{"call_count": 50}' } }

  before do
    allow(FACEBOOK_CACHE).to receive(:get).with("new_feed")      { nil }
    allow(FACEBOOK_CACHE).to receive(:get).with("fresh_feed")    { fresh_feed }
    allow(FACEBOOK_CACHE).to receive(:get).with("stale_feed")    { stale_feed }

    allow(HTTParty).to receive(:get).with(api_request) { api_response }
    allow(api_response).to receive(:parsed_response) { parsed_response }
    allow(api_response).to receive(:headers) { response_headers }

    allow(API_STATUS).to receive(:get)
                          .with(:facebook)
                          .and_return(api_utilization, API_STATUS.get(:facebook))
  end

  subject { described_class.new(page_id).fetch_from_cache_or_api }

  describe "fetch_from_cache_or_api for new page request that is not found in memory" do
    let(:page_id) { "new_feed" }
    let(:api_utilization) { ideal_api_utilization }

    it "hits the API for any brand new request" do
      allow(API_STATUS).to receive(:get).with(:facebook) { ideal_api_utilization }
      expect(HTTParty).to receive(:get).with(api_request) { api_response }
      subject
    end
  end

  describe "fetch_from_cache_or_api when feed is stored in memory" do
    let(:page_id) { "fresh_feed" }
    let(:api_utilization) { ideal_api_utilization }

    it "will not hit the api when recently cached data is avaiable" do
      expect(HTTParty).to_not receive(:get)
      subject
    end

    it "serves the correct data from the cache" do
      expect(subject).to eq JSON.parse(fresh_feed)["data"]
    end

    it "updates the API_STATUS for subsequent requests" do
      subject
      expect(JSON.parse(API_STATUS.get(:facebook))["status"]).to eq(50)
    end
  end

  describe "fetch_from_cache_or_api when API rate limit is underutilized" do
    let(:api_utilization) { underutilized_api }

    before do
      current_time = Time.now
      allow(Time).to receive(:now) { current_time }
    end

    ["new_feed","fresh_feed","stale_feed"].each do |facebook_page_id|
      let(:page_id) { facebook_page_id }

      it "hits the Facebook API for all requests" do
        expect(HTTParty).to receive(:get).with(api_request) { api_response }
        subject
      end

      it "serves the correct data from the API response" do
        expect(subject).to eq parsed_response
      end

      it "updates the cache with the new data" do
        expect(FACEBOOK_CACHE).to receive(:set).with(page_id, { time: Time.now, data: parsed_response }.to_json)
        subject
      end
    end
  end

  describe "fetch_from_cache_or_api when API rate limit is approaching 100%" do
    let(:api_utilization) { overutilized_api }

    ["new_feed","fresh_feed","stale_feed"].each do |facebook_page_id|
      let(:page_id) { facebook_page_id }

      it "serves data from the cache" do
        expect(HTTParty).to_not receive(:get)
        expect(FACEBOOK_CACHE).to receive(:get).with(page_id)
        subject
      end
    end
  end

  describe "API has not been hit in the last hour" do
    let(:api_utilization) { api_sitting_idle }

    ["new_feed","fresh_feed","stale_feed"].each do |facebook_page_id|
      let(:page_id) { facebook_page_id }

      it "hits the Facebook API for any request" do
        expect(HTTParty).to receive(:get).with(api_request) { api_response }
        subject
      end
    end
  end

  # In case API_STATUS.get(:facebook) returns nil after some catastrophic error
  describe "Graceful recovery from a wiped from redis store" do
    let(:page_id) { "new_feed" }
    let(:api_utilization) { nil }

    it "hits the Facebook API" do
      expect(HTTParty).to receive(:get).with(api_request) { api_response }
      subject
    end

    it "updates the API_STATUS" do
      subject
      expect(JSON.parse(API_STATUS.get(:facebook))["status"]).to eq(50)
    end
  end

  describe "API is maxed and request has not been cached" do
    let(:page_id) { "new_feed" }
    let(:api_utilization) { overutilized_api }
    let(:api_error_response) {{data: [{ id:"1",
                                        message: "The Facebook API is currently down. Please try again later",
                                        from: { id: "", name: "Facebook" }}]}}

    it "Does not hit a maxed API for new requests" do
      expect(HTTParty).to_not receive(:get)
      subject
    end

    it "serves the correct data from the API response" do
      expect(subject).to eq api_error_response
    end
  end
end
