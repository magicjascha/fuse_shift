require 'hasher'

class ApplicationController < ActionController::Base
  include Hasher
  include RegistrationsHelper
  protect_from_forgery with: :exception
  
  private
    def authenticate
      authenticate_or_request_with_http_basic(Rails.configuration.x.website_title) do |username, password|
        session[:city] = username
        Rails.configuration.x.auth_users.has_key?(username) && BCrypt::Password.new(Rails.configuration.x.auth_users[username]) == password
      end
    end  
end