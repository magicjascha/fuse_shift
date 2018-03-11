class RegistrationsController < ApplicationController
  
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.valid?
      @registration[:created_at] = Time.now
      @registration.to_csv
      render html: Time.now.strftime("Done. Look in file #{@registration[:created_at].strftime('%Y-%m-%dT%H%M%S')}")
    else
      render html: "Nope"
    end
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end

end

