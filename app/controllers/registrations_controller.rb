class RegistrationsController < ApplicationController
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.save
      render html: "Done."
      # TODO - create 'registration-sucess' view - stating to check mail and confirm registration 
    else 
      render 'new'
    end
  end
  
  private

    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end
end
