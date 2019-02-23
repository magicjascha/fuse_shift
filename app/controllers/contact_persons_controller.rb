class ContactPersonsController < ApplicationController
  include ActionView::Helpers::TextHelper
  
  if Rails.env.test? || Rails.env.development?
    before_action {|controller| session[:city] = "testCity"} 
  else
    before_action :authenticate
  end
  
  def new
    @contact_person = ContactPerson.new()
  end
  
  def create
    hashed_email = digest(contact_person_params[:hashed_email])
    @contact_person = ContactPerson.new(contact_person_params)
    if @contact_person.valid?
      @contact_person = ContactPerson.find_or_create_by(hashed_email: hashed_email)
      session[:contact_person] = contact_person_params[:hashed_email]
      @contact_person.save(validate: false)
      if !@contact_person.confirmed
        ContactPersonMailer.confirm(@contact_person, session[:contact_person]).deliver_now
        render 'create_success'
      else 
        redirect_to root_path
      end
    else
      render 'new'
    end
  end
    
  def delete
    session[:contact_person] = nil
    redirect_to login_path
  end
  
  #disabled feature
#   def clean_browser
#     reset_session
#     flash[:danger] = simple_format(I18n.t("flash.delete_cookie_data"))
#     redirect_to login_path
#   end
  
  def warning
    @contact_person = ContactPerson.find_by(hashed_email: params[:hashed_email])
  end
  
  def confirm
    @contact_person = ContactPerson.find_by(hashed_email: params[:hashed_email])
    @contact_person.confirmed = true
    @contact_person.save(validate: false)
    flash[:danger] = simple_format(I18n.t("flash.contact_person_confirm"))
    redirect_to root_url
  end
  
  private
    def contact_person_params
      c = params.require(:contact_person).permit(:hashed_email)
      c[:hashed_email].downcase!
      c
    end 
end


