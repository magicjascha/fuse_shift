require 'digest'

module RegistrationsHelper
  def registrations_path
    "/registrations"
  end
  
  def registration_path(foobar)
    "/registrations"#this is just because it works for rendering the form. probably this needs to be corrected for the update-post.
  end

end
