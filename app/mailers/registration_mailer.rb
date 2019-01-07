class RegistrationMailer < ApplicationMailer
  add_template_helper(RegistrationsHelper)
  
  default from: "no-reply@festival-registration.de"
  
  def registration_confirm(registration, data)
    @data = data
    @registration = registration
    mail(to: @data[:email], subject: I18n.t("mail.registration_confirm.subject"))
  end
  
  def registration_contact_person(registration, data)
    @data = data
    @registration = registration
    mail(to: @data[:contact_persons_email], subject: I18n.t("mail.registration_contact_person.subject", id: @data[:id]))
  end
  
  def updated_to_contact_person(data, memory_loss)
    @memory_loss = memory_loss
    @data = data
    mail(to: @data[:contact_persons_email], subject: I18n.t("mail.updated_to_contact_person.subject",id: @data[:id]))
  end
  
end
