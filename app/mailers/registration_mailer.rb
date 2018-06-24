class RegistrationMailer < ApplicationMailer
  add_template_helper(RegistrationsHelper)
  
  default from: "no-reply@festival-registration.de"
  
  def registration_confirm(registration, data)
    @data = data
    @registration = registration
    mail(to: @registration.email, subject: 'Confirm your registration for the festival')
  end
  
  def registration_contact_person(registration, data)
    @data = data
    @registration = registration
    mail(to: @registration.contact_person, subject: 'You registered somone for the festival')
  end
end
