require 'json'

class RegistrationsController < ApplicationController
  PEM = File.read('config/keys/public.dev.pem')
  
  def new
    @registration = Registration.new
  end
  
  def create
    @registration = Registration.new(registration_params)
    if @registration.valid?
      Registration.new(encrypted_params).save(validate: false)
      @data = registration_params #contains params that should be displayed in success
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
    registration = Registration.find_by(hashedEmail: params[:hashed_email])
    
    present_attributes = registration_params.select{|key,value| value.present?}
    @registration.update_attributes(present_attributes)
    @registration.assign_attributes(registration_params)
    p @registration
    p registration_params 
    render 'edit'
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person)
    end
    
    def encrypted_params
      registration_params.to_h.map do |key, value|
        value = encrypt(value) if encrypt?(key)
        [key, value]
      end.to_h
    end
    
    def encrypt?(key)
      ![:is_member, :hashedEmail].include?(key)
    end
    
    def encrypt(value)
      Encrypt::Encryptor.new(value, PEM).apply
    end
end
