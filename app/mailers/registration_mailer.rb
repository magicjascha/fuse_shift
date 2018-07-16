class RegistrationMailer < ApplicationMailer
  add_template_helper(RegistrationsHelper)
  
  default from: "no-reply@festival-registration.de"
  
  def registration_confirm(registration, data)
    @data = data
    @registration = registration
    mail(to: @registration.email, subject: I18n.t("mail.registration_confirm.subject"))
  end
  
  def registration_contact_person(registration, data)
    @data = data
    @registration = registration
    mail(to: @registration.contact_person, subject: I18n.t("mail.registration_contact_person.subject"))
  end
  
  def edit(registration, data)
    @data = data
    mail(to: @registration.email, subject: I18n.t(mail.edit.subject))
  end
  
  def updated_to_contact_person(registration, data)
    @data = data
    @registration = registration
    mail(to: @data[:contact_person], subject: I18n.t("mail.updated_to_contact_person.subject")) if @data[:contact_person]
  end
  
end
