require 'digest'

module RegistrationsHelper
  
  def associated_registrations
    @contact_person = ContactPerson.find_by(hashed_email: digest(session[:contact_person]))
    @contact_person.registrations
  end
  
  def accessed_registration
    Registration.find_by(hashed_email: params[:hashed_email])
  end
  
  def replace_with_name(id)
    hashed_email = Registration.find_by(id: id).hashed_email
    !!session[hashed_email] ? session[hashed_email]["name"] : ""
  end
  
  #change formats of registration values in mails and views
  def better_read(value)
    if value.respond_to?(:strftime)
      l(value, format: :short_datetime)
    elsif value == "1" or value==true
      "Yes"
    elsif value == "0" or value==false or value==nil
      "No"
    elsif value == "" and !@session_state
     "[as before]"
    else
      value
    end
  end 
end
