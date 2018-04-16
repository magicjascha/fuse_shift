require 'json'

class RegistrationsController < ApplicationController
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.save
      @data = registration_params
      render "success"    
    else 
      render 'new'
    end
  end
  
  def edit
    id = Registration.find_by(hashedEmail: params[:hashed_email]).id
    @registration = Registration.new(id: id, hashedEmail: params[:hashed_email])
    ##don't display the encrypted stuff in the edit-view or delete @registration and update/save only when field is not empty.
  end
  
  def update
    #post to edit    
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end
end
