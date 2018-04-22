require 'hasher'

class ApplicationController < ActionController::Base
  include Hasher
  include RegistrationsHelper
  protect_from_forgery with: :exception
end
