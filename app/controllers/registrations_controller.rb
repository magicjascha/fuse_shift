require 'json'
require 'aes'

class RegistrationsController < ApplicationController
  if Rails.env.test? || Rails.env.development?
    before_action {|controller| session[:city] = "testCity"} 
  else
    before_action :authenticate, except: :confirm
  end
  
  before_action :check_contact_person, except: :confirm
     
  def index
    scope = Registration
    scope = params[:confirmed] ? scope.where(confirmed: true) : scope.all
    render json: scope.as_json
  end
  
  def new
    @registration = Registration.new
    @registration.city = session[:city]
    @registration.contact_persons_email = session[:contact_person]
  end
  
#   def localstorage_save
#     @data = registration_params
#     @encrypted_data = AES.encrypt(@data.to_json, Rails.configuration.x.symkey)  
#     @hashed_email = digest(@data[:email])
#     render 'localstorage_save' #forwards to edit
#   end
  
  def decrypt
#     debugger
    response = decrypt_params[:encrypted_registrations].to_h.map do |hashed_email, data|
      if data!=""
        [hashed_email, JSON.parse(AES.decrypt(data, Rails.configuration.x.symkey))]
      else
        p "data of #{hashed_email} was empty"
        ""
      end
    end
    render json: response
  end
  
  def create #add hashed_email, validate that and the raw input data, save encrypted data without validation
    #create registration for validation
    @registration = Registration.new(add_hashed_email(registration_params))
    if @registration.valid?
      #save asymatrically encrypted data to database
      @saved_registration = Registration.new(params_encrypt(add_hashed_email(registration_params)))
      @saved_registration.save(validate: false)
      #success message in flash with link to new registration
      flash[:danger] = ActionController::Base.helpers.simple_format(t("views.create_success.red_html", name: @registration.name, registration_link: ActionController::Base.helpers.link_to(t("views.create_success.registration_link_text"), root_url)))
      @data = displayed_data(@saved_registration.id) #contains params displayed in emails and saved to localstorage
      #send emails with plain data
      RegistrationMailer.registration_confirm(@registration, @data).deliver_now
      RegistrationMailer.registration_contact_person(@registration, @data).deliver_now
      #save symmetrically encrypted data to the localstorage 
      @encrypted_data = AES.encrypt(@data.to_json, Rails.configuration.x.symkey)
      @hashed_email = digest(@data[:email])
      render 'localstorage_save' #forwards to edit
    else
      @registration.start=nil if @registration.errors.include?(:start) && registration_params.value?("1970-01-01 15:00:00")
      @registration.end=nil if @registration.errors.include?(:end) && registration_params.value?("1970-01-01 15:00:00")
      render 'new'
    end
  end
  
  def edit #identify record by hashed_email, display an otherwise empty record in the view.
    if accessed_registration == nil
      render 'deleted'
    else 
      id = Registration.find_by(hashed_email: params[:hashed_email]).id
      @registration = Registration.new(id: id, hashed_email: params[:hashed_email])
      @registration.city = session[:city]
      @registration.contact_persons_email = session[:contact_person]
    end
  end

  def update #validate raw input data, identify record by hashed_email, and save encrypted input without validation
    present_attributes = registration_params.select{|key,value| value.present?}
    @registration = Registration.new(present_attributes)
    @session_state = !!params[:hashed_email]
    if @registration.valid?
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.assign_attributes(params_encrypt(present_attributes))
      @registration.save(validate: false)
      @data = displayed_data(@registration.id)
      RegistrationMailer.updated_to_contact_person(@data, @session_state).deliver_now
      render:'update_success'
    else 
      @registration.hashed_email = params[:hashed_email]
      render 'edit'
    end
  end
  
  def confirm
    if accessed_registration == nil
      render 'deleted'
    else 
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.confirmed = true
      @registration.save(validate: false)
      render 'confirm'
    end
  end
  
  def delete
    @registration = Registration.find_by(hashed_email: params[:hashed_email])
    flash[:danger] = "You successfully deleted the registration of #{replace_with_name(@registration.id)} ID #{@registration.id}."
    @registration.destroy
    session[params[:hashed_email]]=nil
    redirect_back(fallback_location: root_path)
  end

  private
  
    def decrypt_params
      params.permit(encrypted_registrations: {})
    end
  
    def registration_params #permits params, downcases email, adds contact_persons email, city and id, transforms start and end date
      input = params.require(:registration).permit(:name, :shortname, :email, :phonenumber, :german, :english, :french, :city, :is_friend, :contact_persons_email, :comment, "start(1i)", "start(2i)", "start(3i)", "start(4i)", "start(5i)", "end(1i)", "end(2i)", "end(3i)", "end(4i)", "end(5i)")
      
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
      r[:contact_persons_email] = session[:contact_person]
      r[:city] = session[:city]
      r[:email].downcase! if input[:email]
      r[:contact_person_id] = ContactPerson.find_by(hashed_email: digest(session[:contact_person])).id
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
      hash.merge!(hashed_email: digest(hash[:email]))
    end
    
    def params_encrypt(params)
      params.to_h.map do |key, value|
      value = encrypt(value.to_s) if encrypt?(key)
        [key, value]
      end.to_h                     
    end
    
    def encrypt?(key)
      !["hashed_email", "confirmed", "start", "end", "contact_person_id"].include?(key)
    end
    
    def encrypt(value)
      Encrypt::Encryptor.new(value, Rails.configuration.x.pem).apply
    end
    
    def authenticate
      authenticate_or_request_with_http_digest(I18n.t("website_title")) do |username|
        session[:city] = username
        Rails.configuration.x.users[username]
      end
    end      
    
    def check_contact_person
      redirect_to login_path unless session[:contact_person] and ContactPerson.find_by(hashed_email: digest(session[:contact_person])).confirmed
    end
    
    def displayed_data(id)
      data = registration_params
      data[:id]=id
      data.delete(:contact_person_id)
      data
    end
      
      
end
