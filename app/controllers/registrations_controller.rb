require 'json'

class RegistrationsController < ApplicationController
  before_action :protect, :only => :success
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.save
#       session[:data]=JSON.dump(registration_params)
      session[:data]=registration_params
      redirect_to success_path     
    else 
      render 'new'
    end
  end
  
  def success
    p session[:data]
#     @data = JSON.parse(session[:data])
    @data = session[:data] || {}
    render "success"
    reset_session
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end
    def protect
      redirect_to root_path unless session[:data]
    end
end
