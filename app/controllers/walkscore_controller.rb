require 'uri'
class WalkscoreController < ApplicationController
  caches_action :show, expires_in: 12.hours

  def walkscore_uri_method(walkscore_client)
    fields = {
      :address => params[:address],
      :city => params["city"],
      :state => params["state"],
      :lat => params["lat"],
      :lon => params["lon"]
    }
    walkscore_score_uri = URI.encode("http://api.walkscore.com/score?format=json&address=#{fields[:address]}#{fields[:city]}#{fields[:state]}&lat=#{fields[:lat]}&lon=#{fields[:lon]}&wsapikey=#{ENV['WALKSCORE_API_KEY']}")
    response = HTTParty.get(walkscore_score_uri)
  end

  def show
    walkscore_json = "[]"
    walkscore_json = walkscore_uri_method(params[:walkscore_client]).parsed_response

    # Walkscore widget treats a response of "[]" as an error and hides the widget.
    # But, it doesn't know what to do with a {"status":30}. So, use this as a band
    # aid until we can rework this whole endpoint into something more robust and 
    # somewhat testable. 
    if [2,30,31,40,41,42].include? walkscore_json["status"]
      puts "\n*****************\n Bad Walkscore API Status Code: \n #{walkscore_json['status']} \n#{params[:walkscore_client]} \n*****************\n"
      walkscore_json = []
    end

    render json: walkscore_json
  end
end