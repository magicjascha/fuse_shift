# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  
  def registration_confirm_preview
    data = {}
    RegistrationMailer.registration_confirm(Registration.last, data)
  end
  
end
