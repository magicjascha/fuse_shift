require 'digest'

module RegistrationsHelper
  
  def registration_path(registration)
    "/registrations/#{registration.hashed_email}"
  end
  
  def registration_url(registration)
    path = registration_path(registration)
    "#{root_url}#{path[1,path.length-1]}"
  end
  
  def registration_confirm_url(registration)
    path = registration_path(registration)
    "#{root_url}#{path[1,path.length-1]}/confirm"
  end
  
  #change formats of registration values in mails and views
  def better_read(value)
    if value.instance_of?(DateTime)
      l(value, format: :short_datetime)
    elsif value == "1" 
      "Yes"
    elsif value == "0"
      "No"
    else
      value
    end
  end 
end
