class ApiStatusController < ApplicationController
  def index
    @facebook_status = JSON.parse(API_STATUS.get(:facebook))
  end
end
