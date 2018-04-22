require 'json'

class RegistrationsController < ApplicationController
  def new
    @registration = Registration.new
  end
  
  def create
    print "print action   "
    puts params[:action]
    print "print registration_params   "
    p registration_params
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
    print "print action   "
    puts params[:action]
    @registration = Registration.find_by(hashedEmail: params[:hashed_email])
    @registration.update(registration_params)
    print "print @registration   "
    p @registration
    @registration.save #fix: Empty Fields should not be saved
    render registration_path(@registration)
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end
end
