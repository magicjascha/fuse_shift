require 'json'

class RegistrationsController < ApplicationController
  PEM = File.read('config/keys/public.dev.pem')
#   USERS = { 'me' => '@home', 'you' => '@work' }
#   before_action :authenticate, only: :new
  
  
#   def authenticate
#     p request.env['HTTP_AUTHORIZATION']
#     USERS.has_key?(name) && USERS[name] == password
#   end
#   http_basic_authenticate_with do |name, password|
#     USERS.has_key?(name) && USERS[name] == password
#   end
#   http_basic_authenticate_with name: "me", password: "@home"
  
  def index
    render json: Registration.all.to_json
  end
  
  def new
    @registration = Registration.new
  end
  
  def create #add hashedEmail, validate that and the raw input data, save encrypted data without validation
    @registration = Registration.new(add_hashed_email(registration_params))
    if @registration.valid?
      Registration.new(add_hashed_email(params_encrypt(registration_params))).save(validate: false)
      @data = registration_params #contains params that should be displayed in success
      RegistrationMailer.registration_confirm(@registration).deliver_now
      render "success"    
    else 
      render 'new'
    end
  end
  
  def edit #identify record by hashedEmail, display an otherwise empty record in the view.
    id = Registration.find_by(hashedEmail: params[:hashed_email]).id
    @registration = Registration.new(id: id, hashedEmail: params[:hashed_email])
  end

  def update #validate raw input data, identify record by hashedEmail, and save encrypted input without validation
    present_attributes = registration_params.select{|key,value| value.present?}
    @registration = Registration.new(present_attributes)
    if @registration.valid?
      @registration = Registration.find_by(hashedEmail: params[:hashed_email])
      @registration.assign_attributes(params_encrypt(present_attributes))
      @registration.save(validate: false)
      @data = present_attributes #contains params that should be displayed in success
      render:'update_success'
    else 
      @registration.hashedEmail = params[:hashed_email]
      render 'edit'
    end
  end
  
  def confirm
    @registration = Registration.find_by(hashedEmail: params[:hashed_email])
    @registration.confirmed = true
    @registration.save(validate: false)
    render 'confirm'
  end

  private
    def registration_params
      r = params.require(:registration).permit(:name, :email, :phonenumber, :city, :is_member, :contact_person, :start)
      r[:email].downcase! if r[:email]
      r
    end
    
    def add_hashed_email(hash)
      hash.merge!(hashedEmail: digest(params[:registration][:email]))
    end
    
    def params_encrypt(params)
      params.to_h.map do |key, value|
        value = encrypt(value) if encrypt?(key)
        [key, value]
      end.to_h                     
    end
    
    def encrypt?(key)
      !["is_member", "hashedEmail", "confirmed"].include?(key)
    end
    
    def encrypt(value)
      Encrypt::Encryptor.new(value, PEM).apply
    end
end
