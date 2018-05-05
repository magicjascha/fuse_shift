class RegistrationMailer < ApplicationMailer
  add_template_helper(RegistrationsHelper)
  
  default from: "no-reply@festival-registration.de"
  
  def registration_confirm(registration)
    @registration = registration
    mail(to: @registration.email, subject: 'Confirm your registration for the festival')
  end
end
