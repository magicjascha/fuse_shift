require 'digest'

module RegistrationsHelper
  
  def registration_path(registration)
    "/registrations/#{registration.hashedEmail}"
  end

end
