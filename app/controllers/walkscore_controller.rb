require 'uri'
class WalkscoreController < ApplicationController
  #caches_action :show, expires_in: 12.hours
  
  def show
    walkscore_json = "[]"

    #Utilize Client URN & Location URN from G5HUB to find canonical address/lat/long
    walkscore_client = params[:walkscore_client]
    walkscore_location = params[:walkscore_location]

    #G5 Hub endpoint
    json_endpoint = walkscore_location.blank? ? "#{walkscore_client}.json" : "#{walkscore_client}/locations/#{walkscore_location}.json"

    #Need to Account for a Client Site Only utilizing this string, would have to update client on hub to include lat / long.
    location_info = URI.encode("http://g5-hub.herokuapp.com/clients/#{json_endpoint}")

    location_response = HTTParty.get(location_info)

    #Access the values from the G5 Hub lookup & pass it to Walkscore API
    if location_response.parsed_response["location"]
      address = location_response.parsed_response["location"]["street_address_1"]
      city = location_response.parsed_response["location"]["city"]
      state = location_response.parsed_response["location"]["state"]
      lat = location_response.parsed_response["location"]["latitude"]
      lon = location_response.parsed_response["location"]["longitude"]

      walkscore_score_uri = URI.encode("http://api.walkscore.com/score?format=json&address=#{address} #{city} #{state}&lat=#{lat}&lon=#{lon}&wsapikey=#{ENV['WALKSCORE_APP_SECRET']}")

      response = HTTParty.get(walkscore_score_uri)

      walkscore_json = response.parsed_response
    end
    render json: walkscore_json
  end
end