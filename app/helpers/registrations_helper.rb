require 'digest'

module RegistrationsHelper
  def registrations_path
    "/registrations"
  end
  
  def registration_path(registration)
    "/registrations/#{registration.hashed_email}"
  end

end
