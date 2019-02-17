require 'json'
require 'aes'
require 'colorize'
# require 'bcrypt'

class RegistrationsController < ApplicationController
  if Rails.env.test? || Rails.env.development?
    before_action {|controller| session[:city] = "testCity"} 
  else
    before_action :authenticate, except: [:confirm, :index]
  end
  
  before_action :check_contact_person, except: [:confirm, :index]
  before_action :auth_admin, only: :index
     
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
  
  #decrypts symmterically encrypted data in localstorage
  def decrypt
    #decrypt_params[:encrypted_registrations] is an array of records from the localstorage, that should be decrypted. Structured like this: [[hashed_email_1, data_hash_1],[hashed_email_2, data_hash_2],...]
    response = decrypt_params[:encrypted_registrations].to_h.map do |hashed_email, data|
      if data!=""
        [hashed_email, JSON.parse(AES.decrypt(data, Rails.configuration.x.symkey))]
      else
        ""
      end
    end
    #set status of changed_on and memory_loss in localstorage
    if response.length == 1 and response != [""]
      localstorage_time = DateTime.parse(response[0][1]["changed_on"])
      datebase_time = Registration.find_by(hashed_email: response[0][0]).updated_at
      timegap = (datebase_time - localstorage_time).abs
      response[0][1]["memory_loss"] = "last time" if timegap > 1.second
    end
    render json: response
  end
  
  def create #add hashed_email, validate, save encrypted data without validation
    #create registration for validation
    @registration = Registration.new(add_hashed_email(registration_params))
    if @registration.valid?
      #save asymetrically encrypted data to database
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
    if @registration.valid?
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.assign_attributes(params_encrypt(present_attributes))
      @registration.save(validate: false)
      #send email with @data, need memory_loss-info for format
      @data = displayed_data(@registration.id)
#       byebug
      RegistrationMailer.updated_to_contact_person(@data, !params["memory_loss"].blank?).deliver_now
      #add browser-memory-loss-info to data and save symmetrically encrypted to the localstorage
      @data["memory_loss"] = "before last time" if !params["memory_loss"].blank?
      @encrypted_data = AES.encrypt(@data.to_json, Rails.configuration.x.symkey)
      @hashed_email = params[:hashed_email]
      flash[:danger] = ActionController::Base.helpers.simple_format(t("flash.update_success"))
      render:'localstorage_save' #forwards to edit
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
      @registration.save(validate: false, touch: false)
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
  
  def shift_confirm_yes
    if accessed_registration == nil
      render 'deleted'
    else
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.shift_confirmed = true
      @registration.save(validate: false)
      render 'shift_confirm_yes'
    end
  end
  
  def shift_confirm_no
    if accessed_registration == nil
      render 'deleted'
    else
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.shift_confirmed = false
      @registration.save(validate: false)
      render 'shift_confirm_no'
    end
  end

  private
  
    def decrypt_params
      params.permit(encrypted_registrations: {})
    end
  
    def registration_params #permits params, downcases email, adds contact_persons email, city and id
      input = params.require(:registration).permit(:name, :shortname, :email, :phonenumber, :german, :english, :french, :city, :is_friend, :contact_persons_email, :comment, "start", "end")
      r = input
      r[:contact_persons_email] = session[:contact_person]
      r[:city] = session[:city]
      r[:email].downcase! if input[:email]
      r[:contact_person_id] = ContactPerson.find_by(hashed_email: digest(session[:contact_person])).id
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
      !["hashed_email", "confirmed", "contact_person_id"].include?(key)
    end
    
    def encrypt(value)
      Encrypt::Encryptor.new(value, Rails.configuration.x.pem).apply
    end
    
    def auth_admin
      authenticate_or_request_with_http_basic(Rails.configuration.x.website_title) do |username, password|
      Rails.configuration.x.auth_admin.has_key?(username) && BCrypt::Password.new(Rails.configuration.x.auth_admin[username]) == password
      end
    end
      
    
    def check_contact_person
      redirect_to login_path unless session[:contact_person] and ContactPerson.find_by(hashed_email: digest(session[:contact_person])).confirmed
    end
    
    def displayed_data(id)
      data = registration_params
      data[:id]=id      
      data[:changed_on] = Registration.find_by(id: id).updated_at
      data.delete(:contact_person_id)
      data
    end
end
