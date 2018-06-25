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
  
  def festival_start
    FESTIVAL_START
  end
  
  def festival_end
    FESTIVAL_END
  end
  
  def deadline
    DEADLINE
  end

end
