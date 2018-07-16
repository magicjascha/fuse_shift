require 'json'

class RegistrationsController < ApplicationController
  
  if Rails.env.test? || Rails.env.development?
    before_action {|controller| @city = "testCity"} 
  else
    before_action :authenticate
  end
       
  def authenticate
    authenticate_or_request_with_http_digest(I18n.t("website_title")) do |username|
      @city = username
      Rails.configuration.x.users[username]
    end
  end
   
  def index
    scope = Registration
    scope = params[:confirmed] ? scope.where(confirmed: true) : scope.all
    render json: scope.as_json
  end
  
  def new
    @registration = Registration.new
    @registration.city = @city
    @registration.contact_person = session[:contact_person] if session[:contact_person]#autofill contact_persons email if it's still in the session    
  end
  
  def create #add hashed_email, validate that and the raw input data, save encrypted data without validation
    @registration = Registration.new(add_hashed_email(registration_params))
    if @registration.valid?
      @saved_registration = Registration.new(add_hashed_email(params_encrypt(registration_params)))
      @saved_registration.save(validate: false)
      @data = registration_params #contains params that should be displayed in success
      p @saved_registration
      @data.merge({id: @saved_registration.id})
      RegistrationMailer.registration_confirm(@registration, @data).deliver_now
      RegistrationMailer.registration_contact_person(@registration, @data).deliver_now
      session[:contact_person] = @data[:contact_person]#for new registration
      session[@registration.hashed_email] = @data#for edit
      render "create_success"    
    else
      @registration.start=nil if @registration.errors.include?(:start) && registration_params.value?("1970-01-01 15:00:00")
      @registration.end=nil if @registration.errors.include?(:end) && registration_params.value?("1970-01-01 15:00:00")
      render 'new'
    end
  end
  
  def edit #identify record by hashed_email, display an otherwise empty record in the view.
    id = Registration.find_by(hashed_email: params[:hashed_email]).id
    @registration = Registration.new(id: id, hashed_email: params[:hashed_email])
    if session[params[:hashed_email]]#display old data if it's still in the session
      @data = session[params[:hashed_email]]
      @registration.attributes =  @data
    end
  end

  def update #validate raw input data, identify record by hashed_email, and save encrypted input without validation
    present_attributes = registration_params.select{|key,value| value.present?}
    @registration = Registration.new(present_attributes)
    if @registration.valid?
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.assign_attributes(params_encrypt(present_attributes))
      @registration.save(validate: false)
      @data = present_attributes #contains params that should be displayed in success
      RegistrationMailer.updated_to_contact_person(@registration, @data).deliver_now
      render:'update_success'
    else 
      @registration.hashed_email = params[:hashed_email]
      render 'edit'
    end
  end
  
  def confirm
    @registration = Registration.find_by(hashed_email: params[:hashed_email])
    @registration.confirmed = true
    @registration.save(validate: false)
    render 'confirm'
  end

  private
    def registration_params
      input = params.require(:registration).permit(:name, :shortname, :email, :phonenumber, :german, :english, :french, :city, :is_friend, :contact_person, :comment, "start(1i)", "start(2i)", "start(3i)", "start(4i)", "start(5i)", "end(1i)", "end(2i)", "end(3i)", "end(4i)", "end(5i)")
      
      input["start(1i)"] = Rails.configuration.x.festival_start.year 
      input["start(1i)"] = "1970" if input["start(2i)"] == "" 
      input["start(2i)"] = "01" if input["start(2i)"] == ""
      input["start(3i)"] = "01" if input["start(3i)"] == ""
      input["start(4i)"] = "15" if input["start(4i)"] == ""
      input["end(1i)"] = Rails.configuration.x.festival_end.year
      input["end(1i)"] = "1970" if input["end(2i)"] == ""
      input["end(2i)"] = "01"   if input["end(2i)"] == ""
      input["end(3i)"] = "01"   if input["end(3i)"] == ""
      input["end(4i)"] = "15"   if input["end(4i)"] == ""

      r = input.reject { |k| k.starts_with?("start") || k.starts_with?("end")}
      r[:city] = @city
      r[:email].downcase! if input[:email]

      r[:start] = DateTime.new(input["start(1i)"].to_i,
                               input["start(2i)"].to_i, # month
                               input["start(3i)"].to_i, # day
                               input["start(4i)"].to_i, # hours
                               input["start(5i)"].to_i) # minutes
      r[:end] = DateTime.new(input["end(1i)"].to_i,
                             input["end(2i)"].to_i,
                             input["end(3i)"].to_i,
                             input["end(4i)"].to_i,
                             input["end(5i)"].to_i)
      r
    end
    
    def add_hashed_email(hash)
      hash.merge!(hashed_email: digest(params[:registration][:email]))
    end
    
    def params_encrypt(params)
      params.to_h.map do |key, value|
        value = encrypt(value.to_s) if encrypt?(key)
        [key, value]
      end.to_h                     
    end
    
    def encrypt?(key)
      !["hashed_email", "confirmed", "start", "end"].include?(key)
    end
    
    def encrypt(value)
#       Encrypt::Encryptor.new(value, PEM).apply
      Encrypt::Encryptor.new(value, Rails.configuration.x.pem).apply
    end
end
