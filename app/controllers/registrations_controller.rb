class RegistrationsController < ApplicationController
  
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.valid?
      @registration.save
      render html: "Done."
    else
      render html: "Nope"
    end
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end

end

