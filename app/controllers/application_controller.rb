require 'hasher'

class ApplicationController < ActionController::Base
  include Hasher
  protect_from_forgery with: :exception
end
