require 'spec_helper'

describe RssFeed do
  let(:feed_url) { 'whatever.com/blog/rss-feed' }
  let(:http_response) { double :http_response }
  let(:standard_response) { {rss: {a: 'A', b: 'B', c: 'C'}} }
  let(:string_response) { ' <rss>
                              <a>A</a>
                              <b>B</b>
                              <c>C</c>
                            </rss> ' }



  subject { described_class.new(feed_url).as_json }
  before { allow(HTTParty).to receive(:get).with(feed_url) { http_response } }

  context "standard xml response" do
    before { allow(http_response).to receive(:parsed_response) { standard_response } }

    it "passes on the resulting xml as json" do
      expect(subject).to eq( { results: standard_response }.to_json )
    end
  end

  context "feed is returned as a string" do
    before { allow(http_response).to receive(:parsed_response) { string_response } }

    it "passes on the resulting xml as json" do
      expect(subject).to eq( { results: standard_response }.to_json )
    end
  end
end
