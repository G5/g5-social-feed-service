require 'spec_helper'

describe RssFeed do
  let(:feed_url) { 'whatever.com/blog/rss-feed' }
  let(:http_response) { double :http_response }
  let(:response_body) { ' <rss>
                            <a>A</a>
                            <b>B</b>
                            <c>C</c>
                          </rss> ' }

  subject { described_class.new(feed_url).as_json }

  before do
    allow(HTTParty).to receive(:get).with(feed_url) { http_response }
    allow(http_response).to receive(:parsed_response) { response_body }
  end

  it "passes on the resulting xml as json" do
    expect(subject).to eq( {results: {rss: {a: 'A', b: 'B', c: 'C'}}}.to_json )
  end
end
