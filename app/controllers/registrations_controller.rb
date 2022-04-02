require 'json'
require 'aes'
require 'colorize'

class RegistrationsController < ApplicationController
  if Rails.env.test? || Rails.env.development?
    before_action {|controller| session[:city] = "testCity"}
  else
    before_action :authenticate, except: [:confirm, :index, :shift_confirm_yes, :shift_confirm_no, :shift_confirm_reset]
    # before_action :authenticate, except: [:confirm, :index]
  end
  before_action :check_contact_person, except: [:confirm, :index, :shift_confirm_yes, :shift_confirm_no, :shift_confirm_reset]
  before_action :auth_admin, only: :index

  def index
    scope = Registration
    if params[:confirmed]=="true"
      scope = scope.where(confirmed: true)
    elsif params[:confirmed]=="false"
      scope = scope.where(confirmed: [nil,false])
    elsif params[:shift_confirmed]=="true"
      scope = scope.where(shift_confirmed: true)
    elsif params[:shift_confirmed]=="false"
      scope = scope.where(shift_confirmed: [nil,false])
    else
      scope = scope.all
    end
    scope = scope.order(:city)
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
      flash[:success] = ActionController::Base.helpers.simple_format(t("flash.create_success", name: @registration.shortname))
      @data = displayed_data(@saved_registration.id) #contains params displayed in emails and saved to localstorage
      #send emails with plain data
      email_data = @data.dup
      email_data.delete(:changed_on)
      RegistrationMailer.registration_confirm(@registration, email_data).deliver_now
      RegistrationMailer.registration_contact_person(@registration, email_data).deliver_now
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
      #send email with email_data to contact_person, need memory_loss-info for format
      @data = displayed_data(@registration.id)
      email_data = @data.dup
      email_data.delete(:changed_on)
      RegistrationMailer.updated_to_contact_person(email_data, !params["memory_loss"].blank?).deliver_now
      flash[:success] = ActionController::Base.helpers.simple_format(t("flash.update.success_memoryloss"))
      #send email with @data to registree if no memory loss (=email address gone) occurred
      if params["memory_loss"].blank?
        RegistrationMailer.updated_to_registree(email_data).deliver_now
        flash[:success] = ActionController::Base.helpers.simple_format(t("flash.update.success"))
      end
      #add browser-memory-loss-info to data and save symmetrically encrypted to the localstorage
      @data["memory_loss"] = "before last time" if !params["memory_loss"].blank?
      @encrypted_data = AES.encrypt(@data.to_json, Rails.configuration.x.symkey)
      @hashed_email = params[:hashed_email]
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
    flash[:success] = ActionController::Base.helpers.simple_format(t("flash.delete.success", hashid: @registration.hashed_email))
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
      @registration.save(validate: false, touch: false)
      render 'shift_confirm_yes'
    end
  end

  def shift_confirm_no
    if accessed_registration == nil
      render 'deleted'
    else
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.shift_confirmed = false
      @registration.save(validate: false, touch: false)
      render 'shift_confirm_no'
    end
  end

  def shift_confirm_reset
    if accessed_registration == nil
      render 'deleted'
    else
      @registration = Registration.find_by(hashed_email: params[:hashed_email])
      @registration.shift_confirmed = nil
      @registration.save(validate: false, touch: false)
      render 'shift_confirm_reset'
    end
  end

  private

    def decrypt_params
      params.permit(encrypted_registrations: {})
    end

    def registration_params #permits params, downcases email, adds contact_persons email, city and id
      input = params.require(:registration).permit(:name, :shortname, :email, :phonenumber, :german, :english, :french, :city, :is_friend, :is_palapa, :is_construction, :is_breakdown, :did_work, :did_orga, :wants_orga, :has_secu, :has_secu_registered, :wants_guard, :real_forename, :real_lastname, :contact_persons_email, :comment, "start", "end")
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
      redirect_to login_path unless confirmed_contact_person?
    end

    def displayed_data(id)
      #get data from input, since record is encrypted
      data = registration_params
      #get hashed_email and updated_at from record
      reg = Registration.find_by(id: id)
      data[:hashid]=reg.hashed_email
      data[:changed_on] = reg.updated_at
      #information about contact_person_id is not relevant for users.
      data.delete(:contact_person_id)
      data
    end
end
