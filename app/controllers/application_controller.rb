class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :allow_cross_domain

  def allow_cross_domain
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def not_found
    render text: "404 not found", status: 404
  end
end
