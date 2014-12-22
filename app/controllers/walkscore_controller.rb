require 'uri'
class WalkscoreController < ApplicationController
  caches_action :show, expires_in: 12.hours
  
  def walkscore_hub_info(walkscore_client, walkscore_location)
    #G5 Hub endpoint
    json_endpoint = walkscore_location.blank? ? "#{walkscore_client}" : "#{walkscore_client}/locations/#{walkscore_location}"

    #Need to Account for a Client Site Only utilizing this string, would have to update client on hub to include lat / long.
    location_info = URI.encode("http://g5-hub.herokuapp.com/clients/#{json_endpoint}.json")
    location_response = HTTParty.get(location_info)
  end

  def walkscore_uri_method(walkscore_client, walkscore_location)
    walkscore_get_fields = walkscore_hub_info(walkscore_client, walkscore_location).parsed_response
    fields = {
      :address => walkscore_get_fields["location"]["street_address_1"],
      :city => walkscore_get_fields["location"]["city"],
      :state => walkscore_get_fields["location"]["state"],
      :lat => walkscore_get_fields["location"]["latitude"],
      :lon => walkscore_get_fields["location"]["longitude"]
    }
    walkscore_score_uri = URI.encode("http://api.walkscore.com/score?format=json&address=#{fields[:address]} #{fields[:city]} #{fields[:state]}&lat=#{fields[:lat]}&lon=#{fields[:lon]}&wsapikey=#{ENV['WALKSCORE_APP_SECRET']}")
    response = HTTParty.get(walkscore_score_uri)
  end

  def show
    walkscore_json = "[]"
      walkscore_json = walkscore_uri_method(params[:walkscore_client], params[:walkscore_location]).parsed_response
    render json: walkscore_json
  end
end